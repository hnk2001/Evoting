package com.election.voting.controller;

import java.util.*;
import java.util.NoSuchElementException;
import java.util.stream.Collectors;

import com.election.voting.model.AdminRole;
import com.election.voting.repository.CurrentElectionRepository;
import com.election.voting.response.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.election.voting.DTO.VoterDTO;
import com.election.voting.exception.AdminException;
import com.election.voting.model.Admin;
import com.election.voting.model.Election;
import com.election.voting.model.Voter;
import com.election.voting.repository.ElectionRepository;
import com.election.voting.repository.VoterRepository;
import com.election.voting.service.ElectionService;
import com.election.voting.service.Impl.AdminServiceImpl;

@RestController
@RequestMapping("/api/admin")
public class ElectionController {

    @Autowired
    private ElectionService electionService;

    @Autowired
    private AdminServiceImpl adminServiceImpl;

    @Autowired
    private ElectionRepository electionRepository;

    @Autowired
    private VoterRepository voterRepository;

    @Autowired
    private CurrentElectionRepository currentElectionRepository;

    @PostMapping("/create/election")
    public ResponseEntity<ElectionResponse> createElection(@RequestHeader("Authorization") String jwt,
            @RequestBody Election election) {
        try {
            Admin admin = adminServiceImpl.findAdminProfileByJwt(jwt);
            election.setAdmin(admin);

            ElectionResponse response = electionService.createElection(election, admin);
            if (response.getElection() != null) {
                return new ResponseEntity<>(response, HttpStatus.CREATED);
            } else {
                return new ResponseEntity<>(response, HttpStatus.BAD_REQUEST);
            }
        } catch (Exception e) {
            return new ResponseEntity<>(null, HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    @GetMapping("/get/election/{electionName}")
    public ResponseEntity<Election> getElection(@RequestHeader("Authorization") String jwt,
            @PathVariable("electionName") String electionName) {
        try {
            String lowerCaseElectionName = electionName.toLowerCase();
            Long id = electionService.getElectionIdByName(lowerCaseElectionName);
            Election election = electionService.getElectionById(id);
            return new ResponseEntity<>(election, HttpStatus.OK);
        } catch (Exception e) {
            return new ResponseEntity<>(null, HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    @PutMapping("/update/{electionName}")
    public ResponseEntity<ElectionUpdateResponse> updateElection(
            @RequestHeader("Authorization") String jwt,
            @PathVariable String electionName,
            @RequestBody Election election) {
        try {
            Admin admin = adminServiceImpl.findAdminProfileByJwt(jwt);
            election.setAdmin(admin);
            Long id = electionService.getElectionIdByName(electionName);
            Election election1 = electionService.getElectionById(id);

            ElectionUpdateResponse response = electionService.updateElection(election1.getId(), election, admin);
            if (response.getUpdatedElection() != null) {
                return new ResponseEntity<>(response, HttpStatus.OK);
            } else {
                return new ResponseEntity<>(response, HttpStatus.BAD_REQUEST);
            }
        } catch (Exception e) {
            return new ResponseEntity<>(null, HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    @DeleteMapping("/delete/election/{electionName}")
    public ResponseEntity<String> deleteElection(@RequestHeader("Authorization") String jwt,
            @PathVariable("electionName") String electionName) {
        try {
            Admin admin = adminServiceImpl.findAdminProfileByJwt(jwt);
            electionService.deleteElection(electionName, admin);
            return new ResponseEntity<>("Election deleted successfully", HttpStatus.OK);
        } catch (Exception e) {
            return new ResponseEntity<>(null, HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    // display election by its name
    @GetMapping("/election/{name}")
    public ResponseEntity<?> getElectionByName(@RequestHeader("Authorization") String token,
            @PathVariable("name") String name) throws AdminException {
        try{
            Admin admin = adminServiceImpl.findAdminProfileByJwt(token);

            String lowerCaseElectionName = name.toLowerCase();
            Optional<Election> opt = electionRepository.findByName(lowerCaseElectionName);

            if (opt.isPresent()) {
                Election election = opt.get();

                if (election.getAdmin().getId() == admin.getId()) {
                    return new ResponseEntity<>(election, HttpStatus.ACCEPTED);
                } else {
                    throw new AdminException("You don't have access");
                }
            } else {
                throw new AdminException("election not found");
            }
        }
        catch (AdminException ex){
            AuthResponse response = new AuthResponse();
            response.setMessage(ex.getMessage());
            return new ResponseEntity<>(response,HttpStatus.BAD_REQUEST);
        }
    }

    // display voter list for given election
    @GetMapping("/by-election/{electionName}")
    public ResponseEntity<?> getVotersByElection(@PathVariable String electionName, @RequestHeader("Authorization") String token) throws AdminException {
        try {
            Admin admin = adminServiceImpl.findAdminProfileByJwt(token);
            System.out.println("Api hit");

            // Convert the election name to lowercase for case-insensitive comparison
            String lowercaseElectionName = electionName.toLowerCase();

            // Query the database using a case-insensitive search
            Election election = electionRepository.findByNameIgnoreCase(lowercaseElectionName)
                    .orElseThrow(() -> new NoSuchElementException("Election not found"));

            Admin createdAdmin = election.getAdmin();

            List<VoterDTO> voters = new ArrayList<>();

            if (admin == createdAdmin) {
                switch (election.getAssembly()) {
                    case LOK_SABHA:
                        voters = voterRepository.findVoterByDistrict(election.getLocation())
                                .stream()
                                .map(this::mapToVoterDTO)
                                .collect(Collectors.toList());
                        break;
                    case VIDHAN_SABHA:
                        voters = voterRepository.findVoterByTaluka(election.getLocation())
                                .stream()
                                .map(this::mapToVoterDTO)
                                .collect(Collectors.toList());
                        break;
                    case NAGARADHYAKSHA:
                    case NAGARSEVAK:
                    case GRAM_PANCHAYAT:
                        voters = voterRepository.findVotersByCityOrVillage(election.getLocation())
                                .stream()
                                .map(this::mapToVoterDTO)
                                .collect(Collectors.toList());
                        break;
                }
            }

            return ResponseEntity.ok(new VoterListResponse(voters));
        } catch (NoSuchElementException ex) {
            AuthResponse response = new AuthResponse();
            response.setMessage("Election not found");
            return new ResponseEntity<>(response, HttpStatus.NOT_FOUND);
        } catch (Exception ex) {
            AuthResponse response = new AuthResponse();
            response.setMessage("There are no voters");
            return new ResponseEntity<>(response, HttpStatus.BAD_REQUEST);
        }
    }


    // display voter list for given election (for central admin)
    @GetMapping("/central/by-election/{electionName}")
    public ResponseEntity<?> getVotersByElectionForCentral(@PathVariable String electionName, @RequestHeader("Authorization") String token) throws AdminException {
        try {
            Admin admin = adminServiceImpl.findAdminProfileByJwt(token);
            System.out.println("Api hit");

            // Convert the election name to lowercase for case-insensitive comparison
            String lowercaseElectionName = electionName.toLowerCase();

            // Query the database using a case-insensitive search
            Election election = electionRepository.findByNameIgnoreCase(lowercaseElectionName)
                    .orElseThrow(() -> new NoSuchElementException("Election not found"));

            List<VoterDTO> voters = new ArrayList<>();

                switch (election.getAssembly()) {
                    case LOK_SABHA:
                        voters = voterRepository.findVoterByDistrict(election.getLocation())
                                .stream()
                                .map(this::mapToVoterDTO)
                                .collect(Collectors.toList());
                        break;
                    case VIDHAN_SABHA:
                        voters = voterRepository.findVoterByTaluka(election.getLocation())
                                .stream()
                                .map(this::mapToVoterDTO)
                                .collect(Collectors.toList());
                        break;
                    case NAGARADHYAKSHA:
                    case NAGARSEVAK:
                    case GRAM_PANCHAYAT:
                        voters = voterRepository.findVotersByCityOrVillage(election.getLocation())
                                .stream()
                                .map(this::mapToVoterDTO)
                                .collect(Collectors.toList());
                        break;
                }

            return ResponseEntity.ok(new VoterListResponse(voters));
        } catch (NoSuchElementException ex) {
            AuthResponse response = new AuthResponse();
            response.setMessage("Election not found");
            return new ResponseEntity<>(response, HttpStatus.NOT_FOUND);
        } catch (Exception ex) {
            AuthResponse response = new AuthResponse();
            response.setMessage("There are no voters");
            return new ResponseEntity<>(response, HttpStatus.BAD_REQUEST);
        }
    }



    // Election result percentrage wise using graph
    @GetMapping("/percentage/{electionName}")
    public ResponseEntity<Double> electionPercentage(@RequestHeader("Authorization")String token, @PathVariable String electionName) throws AdminException {
        Admin admin = adminServiceImpl.findAdminProfileByJwt(token);

        String lowerCaseElectionName = electionName.toLowerCase();
        Election election = electionRepository.findByName(lowerCaseElectionName)
                .orElseThrow(() -> new NoSuchElementException("Election not found"));

        Admin createdAdmin = election.getAdmin();
        Long voterCount=0L;
        Long actualVoterCount = 0L;
        Double percentage=0.0;
        String location = election.getLocation();
        Long electionId = election.getId();

        if(admin == createdAdmin){
            // count of all eligible voters for particular election
            switch (election.getAssembly()){
                case LOK_SABHA :
                    voterCount = voterRepository.countVotersByDistrict(location);
                    break;

                case VIDHAN_SABHA:
                    voterCount = voterRepository.countVotersByTaluka(location);
                    break;

                case NAGARADHYAKSHA:
                    voterCount = voterRepository.countVotersByCityOrVillage(location);
                    break;

                case NAGARSEVAK:
                    voterCount = voterRepository.countVotersByCityOrVillage(location);
                    break;

                case GRAM_PANCHAYAT:
                    voterCount = voterRepository.countVotersByCityOrVillage(location);
                    break;
            }

            // actual number of voters who casted vote
            actualVoterCount = currentElectionRepository.countVotersByElectionId(electionId);

            // Perform floating-point division to calculate the percentage
            if (voterCount != 0) { // Avoid division by zero
                percentage = ((double) actualVoterCount / voterCount) * 100;
            }

            System.out.println("------ votercount = "+voterCount+"\nactualvotercount = "+actualVoterCount+"\npercentage = "+percentage);
        }
        return new ResponseEntity<Double>(percentage,HttpStatus.OK);
    }

    // Election result percentage wise using graph for central admin
    @GetMapping("/central/percentage/{electionName}")
    public ResponseEntity<Double> electionPercentageForCentralAdmin(@RequestHeader("Authorization")String token, @PathVariable String electionName) throws AdminException {
        Admin admin = adminServiceImpl.findAdminProfileByJwt(token);

        String lowerCaseElectionName = electionName.toLowerCase();
        Election election = electionRepository.findByName(lowerCaseElectionName)
                .orElseThrow(() -> new NoSuchElementException("Election not found"));


        Long voterCount=0L;
        Long actualVoterCount = 0L;
        Double percentage=0.0;
        String location = election.getLocation();
        Long electionId = election.getId();

            // count of all eligible voters for particular election
            switch (election.getAssembly()){
                case LOK_SABHA :
                    voterCount = voterRepository.countVotersByDistrict(location);
                    break;

                case VIDHAN_SABHA:
                    voterCount = voterRepository.countVotersByTaluka(location);
                    break;

                case NAGARADHYAKSHA:
                    voterCount = voterRepository.countVotersByCityOrVillage(location);
                    break;

                case NAGARSEVAK:
                    voterCount = voterRepository.countVotersByCityOrVillage(location);
                    break;

                case GRAM_PANCHAYAT:
                    voterCount = voterRepository.countVotersByCityOrVillage(location);
                    break;
            }

            // actual number of voters who casted vote
            actualVoterCount = currentElectionRepository.countVotersByElectionId(electionId);

            // Perform floating-point division to calculate the percentage
            if (voterCount != 0) { // Avoid division by zero
                percentage = ((double) actualVoterCount / voterCount) * 100;
            }

            System.out.println("------ votercount = "+voterCount+"\nactualvotercount = "+actualVoterCount+"\npercentage = "+percentage);

        return new ResponseEntity<Double>(percentage,HttpStatus.OK);
    }

    // get election list (only for central admin)
    @GetMapping("/electionList")
    public ResponseEntity<?> getElectionList(@RequestHeader("Authorization") String jwt) throws AdminException{
        try {
            Admin admin = adminServiceImpl.findAdminProfileByJwt(jwt);
            AdminRole role = admin.getRole();
            long id = admin.getId();

            if(role == AdminRole.CENTRAL){
                List<Election> electionList = electionService.getAllElections();
                // Extracting election names from the list
                List<String> electionNames = electionList.stream()
                        .map(Election::getName)
                        .collect(Collectors.toList());

                return ResponseEntity.ok(electionNames);
            }
            else{
                List<Election> electionList = electionService.getAllElectionsByAdminId(id);
                // Extracting election names from the list
                List<String> electionNames = electionList.stream()
                        .map(Election::getName)
                        .collect(Collectors.toList());

                return ResponseEntity.ok(electionNames);
            }
        }
        catch (AdminException ex){
            AuthResponse response = new AuthResponse();
            response.setMessage("There are no elections");
            return new ResponseEntity<>(response,HttpStatus.BAD_REQUEST);
        }
    }

    private VoterDTO mapToVoterDTO(Voter voter) {
        VoterDTO voterDTO = new VoterDTO();
        voterDTO.setCityOrVillage(voter.getCityOrVillage());
        voterDTO.setTaluka(voter.getTaluka());
        voterDTO.setDistrict(voter.getDistrict());
        voterDTO.setState(voter.getState());
        voterDTO.setVoterId(voter.getVoterId());
        return voterDTO;
    }
}