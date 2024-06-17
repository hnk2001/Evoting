package com.election.voting.controller;

import java.time.LocalDateTime;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import com.election.voting.model.Candidate;
import com.election.voting.model.Election;
import com.election.voting.model.Voter;
import com.election.voting.repository.CandidateRepository;
import com.election.voting.repository.ElectionRepository;
import com.election.voting.repository.VoterRepository;
import com.election.voting.service.CandidateService;
import com.election.voting.service.ElectionService;
import com.election.voting.service.VoteService;
import com.election.voting.service.VoterService;

import java.util.NoSuchElementException;

@RestController
@RequestMapping("/voter")
public class VoterController {

    @Autowired
    private VoterService voterService;

    @Autowired
    private VoteService voteService;

    @Autowired
    CandidateService candidateService;

    @Autowired
    ElectionService electionService;

    @Autowired
    private VoterRepository voterRepository;

    @Autowired
    private ElectionRepository electionRepository;

    @Autowired
    private CandidateRepository candidateRepository;

    // Step 1: Verify voter by Aadhaar or Voter ID
    @GetMapping("/get-voterId/{aadhaarNumber}")
    public ResponseEntity<String> voterId(@PathVariable("aadhaarNumber")String aadhaarNumber){
        Voter v = voterRepository.findByAadhaarNumber(aadhaarNumber);
        String voterId = v.getVoterId();
        return new ResponseEntity<String>(voterId, HttpStatus.OK);
    }

    @GetMapping("/verify")
    public ResponseEntity<String> verifyVoter(@RequestParam(value = "voterId", required = false) String voterId,
            @RequestParam(value = "aadhaarNumber", required = false) String aadhaarNumber) {
    
        // Check if Aadhaar number is provided and not empty
        if (aadhaarNumber != null && !aadhaarNumber.isEmpty()) {
            // Retrieve voter information by Aadhaar number
            Voter voterByAadhaar = voterService.getVoterByAadhaarNumber(aadhaarNumber);
    
            // If the voter with the provided Aadhaar number is found
            if (voterByAadhaar != null) {
                    return new ResponseEntity<>("Voter verified by Aadhaar number", HttpStatus.OK);
         
            } else {
                return new ResponseEntity<>("Aadhaar number not found", HttpStatus.NOT_FOUND);
            }
        }
    
        // If Aadhaar number is not provided or not found, and Voter ID is provided
        if (voterId != null && !voterId.isEmpty()) {
            // Retrieve voter information by Voter ID
            Voter voterByVoterId = voterService.getVoterByVoterId(voterId);
    
            // If the voter with the provided Voter ID is not found
            if (voterByVoterId == null) {
                return new ResponseEntity<>("Voter not found", HttpStatus.NOT_FOUND);
            }
            
            // Voter verified by Voter ID
            return new ResponseEntity<>("Voter verified by Voter ID", HttpStatus.OK);
        }
    
        // If neither Aadhaar number nor Voter ID is provided
        return new ResponseEntity<>("Neither Aadhaar number nor Voter ID provided", HttpStatus.BAD_REQUEST);
    }
    

    // Step 3: Choose candidate/party and cast vote
    @PostMapping("/cast-vote")
    public ResponseEntity<String> castVote(@RequestBody Map<String, String> requestBody) {
        try {
            String voterId = requestBody.get("voterId");
            String candidateName = requestBody.get("candidateName");
            String electionName = requestBody.get("electionName");
            String aadhaarNumber = requestBody.get("aadhaarNumber");

            // Fetch candidateId and electionId based on candidateName and electionName
            Long candidateId = candidateRepository.findIdByName(candidateName);

            Long electionId = electionService.getElectionIdByName(electionName);

           voteService.castVote(voterId, aadhaarNumber, candidateId, electionId);
            return ResponseEntity.ok("Vote cast successfully");
        } catch (NoSuchElementException e) {
            return ResponseEntity.badRequest().body(e.getMessage());
        } catch (IllegalStateException e) {
            return ResponseEntity.badRequest().body(e.getMessage());
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("An error occurred");
        }
    }

    @GetMapping("/candidates")
    public Map<String, List<Candidate>> getCandidatesByAadhaarOrVoterId(
        @RequestParam(value = "voterId", required = false) String voterId,
        @RequestParam(value = "aadhaarNumber", required = false) String aadhaarNumber) {
        
        Voter voter = null;
        voter = voterRepository.findByVoterIdOrAadhaarNumber(voterId, aadhaarNumber).orElse(null);
        if (voter == null) {
            return Collections.emptyMap(); // or handle the case where voter is not found more gracefully
        }
    
        List<Election> elections = electionRepository.findAll();
        Map<String, List<Candidate>> candidatesByElection = new HashMap<>();
    
        for (Election election : elections) {
            if (election.getStartTime().isBefore(LocalDateTime.now()) &&
                election.getEndTime().isAfter(LocalDateTime.now())) {
                if (isCandidateEligibleForElection(voter, election)) {
                    List<Candidate> candidates = candidateRepository.findByElectionName(election.getName());
                    candidatesByElection.put(election.getName(), candidates);
                }
            }
        }
    
        return candidatesByElection;
    }

    // Step 4: Check eligibility based on assembly type and location
    private boolean isCandidateEligibleForElection(Voter voter, Election election) {
        switch (election.getAssembly()) {
            case LOK_SABHA:
                return election.getLocation().equalsIgnoreCase(voter.getDistrict());
            case VIDHAN_SABHA:
                return election.getLocation().equalsIgnoreCase(voter.getTaluka());
            case NAGARADHYAKSHA:
                return election.getLocation().equalsIgnoreCase(voter.getCityOrVillage());
            case NAGARSEVAK:
                return election.getLocation().equalsIgnoreCase(voter.getCityOrVillage());
            case GRAM_PANCHAYAT:
                return election.getLocation().equalsIgnoreCase(voter.getCityOrVillage());
            default:
                return false;
        }
    }

}


