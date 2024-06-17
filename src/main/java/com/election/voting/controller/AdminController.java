package com.election.voting.controller;

import java.io.FileNotFoundException;
import java.io.IOException;
import java.sql.Timestamp;
import java.text.ParseException;
import java.time.Instant;
import java.time.LocalDate;
import java.util.*;

import com.election.voting.DTO.AdminDTO;
import com.election.voting.DTO.CandidateDTO;
import com.election.voting.model.*;
import com.election.voting.repository.ElectionRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

import com.election.voting.exception.AdminException;
import com.election.voting.repository.AdminRepository;
import com.election.voting.repository.CandidateRepository;
import com.election.voting.repository.VoterRepository;
import com.election.voting.response.AdminListResponse;
import com.election.voting.response.ApiResponse;
import com.election.voting.response.AuthResponse;
import com.election.voting.response.CandidateListResponse;
import com.election.voting.service.CandidateService;
import com.election.voting.service.VoteService;
import com.election.voting.service.VoterService;
import com.election.voting.service.Impl.AdminServiceImpl;

@RestController
@RequestMapping("/api/admin")
public class AdminController {
    
    @Autowired
    private CandidateService candidateService;

    @Autowired
    AdminRepository adminRepository;

    @Autowired
    private VoterService voterService;

    @Autowired
    private VoterRepository voterRepository;
    
    @Autowired
    private CandidateRepository candidateRepository;

    @Autowired
    private VoteService voteService;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @Autowired 
    private AdminServiceImpl adminServiceImpl;

    @Autowired
    private ElectionRepository electionRepository;

    @GetMapping("/profile")
    public ResponseEntity<Admin> getAdminRole(@RequestHeader("Authorization")String jwt)throws AdminException{

        Admin admin = adminServiceImpl.findAdminProfileByJwt(jwt);

        return new ResponseEntity<Admin>(admin, HttpStatus.ACCEPTED);
    }

    @GetMapping("/get/role")
    public ResponseEntity<Map<String, String>> getAdminProfileHandler(@RequestHeader("Authorization") String jwt) throws AdminException {
        Admin admin = adminServiceImpl.findAdminProfileByJwt(jwt);
        String role = admin.getRole().toString();
        System.out.println(admin.getRole());
        Map<String, String> roleMap = new HashMap<>();
        roleMap.put("role", role);
        return new ResponseEntity<>(roleMap, HttpStatus.OK);
    }

    // create Admin
    @PostMapping("/create")
    public ResponseEntity<?> createAdmin(@RequestBody Admin admin,
                                         @RequestHeader("Authorization") String token) {
        try {
            admin.setPassword(passwordEncoder.encode(admin.getPassword()));

            Optional<Admin> username = adminRepository.findByUsername1(admin.getUsername());
            Optional<Admin> email = adminRepository.findByEmail1(admin.getEmail());
            Optional<Admin>  mobile = adminRepository.findByMobile(admin.getMobile());
            Admin createdAdmin = adminServiceImpl.findAdminProfileByJwt(token);
            admin.setAdmin(createdAdmin);

            if (username.isPresent()) {
                throw new AdminException("username already exists. try different");
            }
            if (email.isPresent()) {
                throw new AdminException("email already exists. try different");
            }
            if (mobile.isPresent()) {
                throw new AdminException("Mobile number already exists");
            }

            admin.setCreatedAt(Timestamp.from(Instant.now()));

            if (admin.getRole() == null) {
                admin.setRole(admin.getRole());
            }

            if (createdAdmin.getRole() == AdminRole.CENTRAL) {
                admin.setRole(AdminRole.STATE);
            } else if (createdAdmin.getRole() == AdminRole.STATE) {
                admin.setRole(AdminRole.CITY_NAGAR_ADHYAKSHA);
            } else if (createdAdmin.getRole() == AdminRole.CITY_NAGAR_ADHYAKSHA) {
                admin.setRole(AdminRole.CITY_NAGAR_SEVAK);
            } else if (createdAdmin.getRole() == AdminRole.CITY_NAGAR_SEVAK) {
                admin.setRole(AdminRole.VILLAGE);
            }

            adminRepository.save(admin);

            AuthResponse authResponse = new AuthResponse();
            authResponse.setMessage("Admin created successfully");

            return new ResponseEntity<>(authResponse, HttpStatus.CREATED);
        } catch (AdminException ex) {
            AuthResponse authResponse = new AuthResponse();
            authResponse.setMessage(ex.getMessage());
            return new ResponseEntity<>(authResponse, HttpStatus.BAD_REQUEST);
        } catch (Exception e) {
            return new ResponseEntity<>(e.getMessage(), HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    @GetMapping("/getByEmail/{email}")
    public ResponseEntity<Admin> getAdminByEmail(@PathVariable String email,@RequestHeader("Authorization") String token) throws AdminException {
        Admin admin = adminServiceImpl.findByEmail(email);
       
        try {
            return new ResponseEntity<Admin>(admin, HttpStatus.OK);
        } catch (Exception e) {
            throw new AdminException("Admin does not exist by email");
        }
        
    }

    @PutMapping("/updateByEmail/{email}")
    public ResponseEntity<?> updateAdmin(@PathVariable String email, @RequestBody Admin updatedAdmin,
            @RequestHeader("Authorization") String token) {
        try {
            Admin createdAdmin = adminServiceImpl.findAdminProfileByJwt(token);
            Admin existingAdmin = adminServiceImpl.findByEmail(email);
            

            if (existingAdmin == null) {
                return ResponseEntity.notFound().build();
            }

            // Update only the provided fields
            if (updatedAdmin.getUsername() != null) {
                existingAdmin.setUsername(updatedAdmin.getUsername());
            }
            if (updatedAdmin.getPassword() != null) {
                existingAdmin.setPassword(passwordEncoder.encode(updatedAdmin.getPassword()));
            }
            if (updatedAdmin.getMobile() != null) {
                existingAdmin.setMobile(updatedAdmin.getMobile());
            }
            if (updatedAdmin.getEmail() != null) {
                existingAdmin.setEmail(updatedAdmin.getEmail());
            }
            if (updatedAdmin.getFullName() != null) {
                existingAdmin.setFullName(updatedAdmin.getFullName());
            }
            if (updatedAdmin.getHouseNoFlatNo() != null) {
                existingAdmin.setHouseNoFlatNo(updatedAdmin.getHouseNoFlatNo());
            }
            
            if (updatedAdmin.getCityOrVillage() != null) {
                existingAdmin.setCityOrVillage(updatedAdmin.getCityOrVillage());
            }
            if (updatedAdmin.getTaluka() != null) {
                existingAdmin.setTaluka(updatedAdmin.getTaluka());
            }
            if (updatedAdmin.getPincode() != null) {
                existingAdmin.setPincode(updatedAdmin.getPincode());
            }
            if (updatedAdmin.getDistrict() != null) {
                existingAdmin.setDistrict(updatedAdmin.getDistrict());
            }
            if (updatedAdmin.getState() != null) {
                existingAdmin.setState(updatedAdmin.getState());
            }
            if (updatedAdmin.getCountry() != null) {
                existingAdmin.setCountry(updatedAdmin.getCountry());
            }

            if (createdAdmin == existingAdmin.getAdmin()) {
                Admin savedAdmin = adminServiceImpl.updateAdmin(existingAdmin);
                return ResponseEntity.ok(savedAdmin);
            } else {
                return ResponseEntity.status(HttpStatus.FORBIDDEN).body("You are not authorized to update this admin.");
            }
        } catch (AdminException e) {
            return ResponseEntity.badRequest().body("Error updating admin: " + e.getMessage());
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body("Internal server error while updating admin: " + e.getMessage());
        }
    }

    @DeleteMapping("deleteByEmail/{email}")
    public ResponseEntity<ApiResponse> deleteAdminByEmail(@RequestHeader("Authorization") String token,
            @PathVariable("email") String email) throws AdminException {
        Admin createAdmin = adminServiceImpl.findAdminProfileByJwt(token);

        Admin existingAdmin = adminRepository.findByEmail(email);

        ApiResponse response = new ApiResponse();
        response.setMessage("Admin deleted successfully");
         response.setStatus(true);
        if (existingAdmin.getAdmin() == createAdmin) {
            Long id = existingAdmin.getId();
            adminRepository.deleteById(id);
            return new ResponseEntity<ApiResponse>(response, HttpStatus.OK);
        }
        throw new AdminException("Admin not found");
    }

    // admin list
    @GetMapping("/list")
    public ResponseEntity<?> getAllAdmins(@RequestHeader("Authorization") String jwt) throws AdminException {
        try {
            System.out.println("==============================");
            Admin admin = adminServiceImpl.findAdminProfileByJwt(jwt);
            Long id = admin.getId();
            List<AdminDTO> admins = adminServiceImpl.getAllCandidates(id);
            if(admins.isEmpty()){
                throw new AdminException("Admin not present");
            }
            Map<String,Object> result = new HashMap<>();
            result.put("admins",admins);
            return ResponseEntity.ok(new AdminListResponse(admins));
        }
        catch (AdminException ex){
            AuthResponse response = new AuthResponse();
            response.setMessage(ex.getMessage());
            return new ResponseEntity<>(response,HttpStatus.BAD_REQUEST);
        }
    }


    // Create Candidate
    @PostMapping("/create/candidate")
    public ResponseEntity<ApiResponse> createCandidate(@RequestHeader("Authorization") String jwt,
            @RequestBody Candidate candidate) {
        try {
            Admin admin = adminServiceImpl.findAdminProfileByJwt(jwt);
            candidate.setAdmin(admin);
            Candidate newCandidate = candidateService.createCandidate(admin, candidate);
            ApiResponse response = new ApiResponse();
            response.setMessage("Candidate created successfully");
            if (newCandidate != null) {
                return new ResponseEntity<>(response, HttpStatus.CREATED);
            } else {
                return new ResponseEntity<>(response, HttpStatus.BAD_REQUEST);
            }
        } catch (Exception e) {
            ApiResponse response = new ApiResponse();
            response.setMessage("There is a problem so candidate not created");
            return new ResponseEntity<>(response, HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    // display candidate by name
    @GetMapping("/get/candidate/{name}")
    public ResponseEntity<?> getCandidateByName(
        @RequestHeader("Authorization") String jwt,
        @PathVariable String name) {
        try {
            System.out.println(name);
            String lowerCaseName = name.toLowerCase();
            Candidate existingCandidate = candidateRepository.findCandidateByName(lowerCaseName);
            if (existingCandidate != null) {
                return new ResponseEntity<>(existingCandidate, HttpStatus.OK);
            } else {
                return new ResponseEntity<>("Candidate not found", HttpStatus.NOT_FOUND);
            }

        } catch (Exception e) {
            return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
        }
    }



    // ---------------------------------- Update Candidate (only that admin have
    // access which is created)
    @PutMapping("/update/candidate/{name}")
    public ResponseEntity<ApiResponse> updateCandidate(
            @RequestHeader("Authorization") String jwt,
            @PathVariable String name,
            @RequestBody Candidate candidate) {
        try {
            Admin admin = adminServiceImpl.findAdminProfileByJwt(jwt);
            candidate.setAdmin(admin);
            Candidate updatedCandidate = candidateService.updateCandidate(name, candidate, admin);
            ApiResponse response = new ApiResponse();
            response.setMessage("Candidate updated successfully");
            if (updatedCandidate != null) {
                return new ResponseEntity<>(response, HttpStatus.OK);
            } else {
                return new ResponseEntity<>(response, HttpStatus.BAD_REQUEST);
            }
        } catch (Exception e) {
            ApiResponse response = new ApiResponse();
            response.setMessage("There is error so candidate not updated");
            return new ResponseEntity<>(response, HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    // Delete Candidate by name
    @DeleteMapping("/delete/candidate/{name}")
    public ResponseEntity<ApiResponse> deleteCandidate(@PathVariable("name") String name,
            @RequestHeader("Authorization") String token) throws AdminException {

        try{
            Admin admin = adminServiceImpl.findAdminProfileByJwt(token);
            Candidate candidate = candidateRepository.findCandidateByName(name);

            candidateService.deleteCandidate(admin, candidate);
            ApiResponse res = new ApiResponse();
            res.setMessage("Candidate deleted ");
            res.setStatus(true);

            return new ResponseEntity<ApiResponse>(res, HttpStatus.OK);
        }
        catch (Exception ex){
            ApiResponse res = new ApiResponse();
            res.setMessage("Candidate not present.");
            res.setStatus(true);

            return new ResponseEntity<ApiResponse>(res, HttpStatus.OK);
        }

    }

    //get candidate list
    @GetMapping("/candidate-list")
    public ResponseEntity<?> getAllCandidates(@RequestHeader("Authorization") String jwt) throws AdminException {
        try {
            Admin admin = adminServiceImpl.findAdminProfileByJwt(jwt);
            Long id = admin.getId();
            List<CandidateDTO> candidates = candidateService.getAllCandidates(id);
            if(candidates.isEmpty()){
                throw new AdminException("Candidate not present");
            }
            return ResponseEntity.ok(new CandidateListResponse(candidates));
        }
        catch (AdminException ex){
            AuthResponse response = new AuthResponse();
            response.setMessage(ex.getMessage());
            return new ResponseEntity<>(response,HttpStatus.BAD_REQUEST);
        }
    }

    //get candidate list (central admin)
    @GetMapping("/all-candidate-list/{electionName}")
    public ResponseEntity<?> getAllCandidatesForCentral(@RequestHeader("Authorization") String jwt, @PathVariable("electionName")String electionName) throws AdminException {
        try {
            Admin admin = adminServiceImpl.findAdminProfileByJwt(jwt);
            Long id = admin.getId();
            List<CandidateDTO> candidates = candidateService.getAllCandidatesForCentral(electionName);
            if(candidates.isEmpty()){
                throw new AdminException("Candidate not present");
            }
            return ResponseEntity.ok(new CandidateListResponse(candidates));
        }
        catch (AdminException ex){
            AuthResponse response = new AuthResponse();
            response.setMessage(ex.getMessage());
            return new ResponseEntity<>(response,HttpStatus.BAD_REQUEST);
        }
    }

    // create voter
   @PostMapping("/create/voter")
    public ResponseEntity<?> createVoter(
            @RequestHeader("Authorization") String jwt,
            @RequestParam("firstName") String firstName,
            @RequestParam("middleName") String middleName,
            @RequestParam("lastName") String lastName,
            @RequestParam("dateOfBirth") String dateOfBirth,
            @RequestParam("gender") String gender,
            @RequestParam("contactNumber") String contactNumber,
            @RequestParam("houseNoFlatNo") String houseNoFlatNo,
            @RequestParam("areaOrWardNo") String areaOrWardNo,
            @RequestParam("cityOrVillage") String cityOrVillage,
            @RequestParam("taluka") String taluka,
            @RequestParam("pincode") String pincode,
            @RequestParam("district") String district,
            @RequestParam("state") String state,
            @RequestParam("country") String country,
            @RequestParam("aadhaarNumber") String aadhaarNumber,
            @RequestParam("voterId") String voterId,
            @RequestParam("aadhaarImage") MultipartFile adhaarImage,
            @RequestParam("voterImage") MultipartFile voterImage
    ) throws AdminException, IOException, ParseException {
        try{
            if (adhaarImage.getSize() > 256 * 1024 || voterImage.getSize() > 256 * 1024) {
                throw new AdminException("Image size exceeds 256KB limit");
            }

            Voter voter = new Voter();
            Admin admin = adminServiceImpl.findAdminProfileByJwt(jwt);
            voter.setAdmin(admin);

            Optional<Voter> voterByMobile = voterRepository.findByMobileNumber(contactNumber);
            Voter voterByAadhar = voterRepository.findByAadhaarNumber(aadhaarNumber);
            Voter voterByVoterId = voterRepository.findByVoterId(voterId);

            if(voterByAadhar != null){
                throw new AdminException("Aadhaar Number is already present");
            }
            if(voterByMobile.isPresent()){
                throw new AdminException("Mobile Number is already present");
            }
            if(voterByVoterId != null){
                throw new AdminException("Voter Id is already present");
            }

            voter.setFirstName(firstName);
            voter.setMiddleName(middleName);
            voter.setLastName(lastName);


            // SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");
            LocalDate date = LocalDate.parse(dateOfBirth);
            voter.setDateOfBirth(date);
            voter.setGender(gender);
            voter.setContactNumber(contactNumber);
            voter.setHouseNoFlatNo(houseNoFlatNo);
            voter.setAreaOrWardNo(areaOrWardNo);
            voter.setCityOrVillage(cityOrVillage);
            voter.setTaluka(taluka);
            voter.setPincode(pincode);
            voter.setDistrict(district);
            voter.setState(state);
            voter.setCountry(country);
            voter.setAadhaarNumber(aadhaarNumber);
            voter.setVoterId(voterId);
            voter.setAdhaarImage(adhaarImage.getBytes());
            voter.setVoterImage(voterImage.getBytes());

            // Your existing logic to create the voter.

            voterService.createVoter(voter);

            AuthResponse response = new AuthResponse();
            response.setMessage("Voter created successfully.");
            return new ResponseEntity<>(response, HttpStatus.CREATED);
        }
        catch (AdminException ex){
            AuthResponse response = new AuthResponse();
            response.setMessage(ex.getMessage());
            return new ResponseEntity<>(response, HttpStatus.BAD_REQUEST);
        }
    }

    @GetMapping("/voter/{voterId}/aadhaarImage")
    public ResponseEntity<byte[]> getAdhaarImage(@RequestHeader("Authorization") String jwt,@PathVariable String voterId) {
        Voter voter = voterRepository.findByVoterId(voterId);
        byte[] adhaarImage = voter.getAdhaarImage();

        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.IMAGE_JPEG);

        return new ResponseEntity<>(adhaarImage, headers, HttpStatus.OK);
    }

    @GetMapping("/voter/{voterId}/voterImage")
    public ResponseEntity<byte[]> getVoterImage(@RequestHeader("Authorization") String jwt,@PathVariable String voterId) {
        Voter voter = voterRepository.findByVoterId(voterId);
        byte[] voterImage = voter.getVoterImage();

        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.IMAGE_JPEG);

        return new ResponseEntity<>(voterImage, headers, HttpStatus.OK);
    }

    @GetMapping("/get/voter/{voterId}")
    public ResponseEntity<?> getVoter(@RequestHeader("Authorization") String jwt, @PathVariable("voterId") String voterId) {
        try {
            Voter existingVoter = voterRepository.findByVoterId(voterId);

            if (existingVoter != null) {
                return new ResponseEntity<>(existingVoter, HttpStatus.OK);
            } else {
                return new ResponseEntity<>("Voter not found", HttpStatus.NOT_FOUND);
            }
        } catch (Exception e) {
            return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }


    @PutMapping("/update/voter/{voterId}")
    public ResponseEntity<Voter> updateVoter(@RequestHeader("Authorization")String jwt,@PathVariable("voterId") String voterId,
    @RequestParam("firstName") String firstName,
    @RequestParam("middleName") String middleName,
    @RequestParam("lastName") String lastName,
    @RequestParam("dateOfBirth") String dateOfBirth,
    @RequestParam("gender") String gender,
    @RequestParam("contactNumber") String contactNumber,
    @RequestParam("houseNoFlatNo") String houseNoFlatNo,
    @RequestParam("areaOrWardNo") String areaOrWardNo,
    @RequestParam("cityOrVillage") String cityOrVillage,
    @RequestParam("taluka") String taluka,
    @RequestParam("pincode") String pincode,
    @RequestParam("district") String district,
    @RequestParam("state") String state,
    @RequestParam("aadhaarImage") MultipartFile adhaarImage,
    @RequestParam("voterImage") MultipartFile voterImage) {
        try {
            Voter existingVoter = voterRepository.findByVoterId(voterId);
            if (existingVoter == null) {
                return new ResponseEntity<>(HttpStatus.NOT_FOUND);
            }
            System.out.println("Voter updation");
            // Update only the attributes that are present in the request body
            //LocalSimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");
            LocalDate date = LocalDate.parse(dateOfBirth);
            
            existingVoter.setFirstName(firstName);
            existingVoter.setMiddleName(middleName);
            existingVoter.setLastName(lastName);
            existingVoter.setDateOfBirth(date);
            existingVoter.setGender(gender);
            existingVoter.setContactNumber(contactNumber);
            existingVoter.setHouseNoFlatNo(houseNoFlatNo);
            existingVoter.setAreaOrWardNo(areaOrWardNo);
            existingVoter.setCityOrVillage(cityOrVillage);
            existingVoter.setTaluka(taluka);
            existingVoter.setPincode(pincode);
            existingVoter.setDistrict(district);
            existingVoter.setState(state);
            existingVoter.setAdhaarImage(adhaarImage.getBytes());
            existingVoter.setVoterImage(voterImage.getBytes());
            Voter savedVoter = voterRepository.save(existingVoter);
            return new ResponseEntity<>(savedVoter, HttpStatus.OK);
        } catch (Exception e) {
            return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    // delete voter
    @DeleteMapping("/delete/voter/{voterId}")
    public ResponseEntity<ApiResponse> deleteVoter(@PathVariable("voterId") String voterId,
                                                   @RequestHeader("Authorization") String token) throws AdminException {

        Admin admin = adminServiceImpl.findAdminProfileByJwt(token);

        voterService.deleteVoter(voterId,admin);
        ApiResponse res = new ApiResponse();
        res.setMessage("voter deleted ");
        res.setStatus(true);

        return new ResponseEntity<ApiResponse>(res, HttpStatus.OK);
    }

    // Get Election Results (for central admin)
    @GetMapping("/central/results/{electionName}")
    public ResponseEntity<?> getElectionResultsForCentralAdmin(@PathVariable String electionName) throws IOException {
        try {
            String lowerCaseElectionName = electionName.toLowerCase();
            Map<String, Long> electionResults = voteService.getElectionResults(lowerCaseElectionName);
            return new ResponseEntity<>(electionResults, HttpStatus.OK);
        } catch (NoSuchElementException e) {
            return new ResponseEntity<>("Election not found", HttpStatus.NOT_FOUND);
        }
    }

    // Get Election Results
    @GetMapping("/results/{electionName}")
    public ResponseEntity<?> getElectionResults(@RequestHeader("Authorization")String token,@PathVariable String electionName) throws IOException, AdminException {
        try {
            Admin admin = adminServiceImpl.findAdminProfileByJwt(token);

            Election election = electionRepository.findByNameIgnoreCase(electionName)
                    .orElseThrow(() -> new NoSuchElementException("Election not found"));

            Admin createdAdmin = election.getAdmin();

            if(admin == createdAdmin){
                String lowerCaseElectionName = electionName.toLowerCase();
                Map<String, Long> electionResults = voteService.getElectionResults(lowerCaseElectionName);
                return new ResponseEntity<>(electionResults, HttpStatus.OK);
            }
            else {
                AuthResponse response = new AuthResponse();
                response.setMessage("You can't access");
                return new ResponseEntity<>(response, HttpStatus.BAD_REQUEST);
            }

        } catch (NoSuchElementException e) {
            return new ResponseEntity<>("Election not found", HttpStatus.NOT_FOUND);
        }
    }
}
