package com.election.voting.service.Impl;

import java.util.NoSuchElementException;

import com.election.voting.model.Admin;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.election.voting.model.Voter;
import com.election.voting.repository.VoterRepository;
import com.election.voting.service.VoterService;

@Service
public class VoterServiceImpl implements VoterService{
    
    @Autowired
    private VoterRepository voterRepository;

    @Override
    public void createVoter(Voter voter) {
        voterRepository.save(voter);
    }

    @Override
    public Voter updateVoter(Long id, Voter updatedVoter) {
        Voter voter = voterRepository.findById(id)
                .orElseThrow(() -> new NoSuchElementException("Voter not found"));
        
        // Update fields with new values
       
        return voterRepository.saveAndFlush(voter);
    }

    @Override
    public void deleteVoter(String voterId, Admin admin) {
        try{
            Voter voter = voterRepository.findByVoterId(voterId);
            Long id = voter.getId();
            Admin voterAdmin = voter.getAdmin();
            if(voterAdmin == admin) {
                voterRepository.deleteById(id);
            }
        }
        catch (Exception e){
            throw new RuntimeException("Voter not found");
        }
    }

    @Override
    public Voter getVoterByAadhaarNumber(String aadhaarNumber) {
        return voterRepository.findByAadhaarNumber(aadhaarNumber);
    }

    @Override
    public Voter getVoterByVoterId(String voterId) {
        return voterRepository.findByVoterId(voterId);
    }

}



 