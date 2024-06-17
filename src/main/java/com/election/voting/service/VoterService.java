package com.election.voting.service;

import com.election.voting.model.Admin;
import com.election.voting.model.Voter;

public interface VoterService {
    Voter getVoterByAadhaarNumber(String aadhaarNumber);
    Voter getVoterByVoterId(String voterId);
    void createVoter(Voter voter);
    Voter updateVoter(Long id, Voter voter);
    void deleteVoter(String voterId, Admin admin);
}