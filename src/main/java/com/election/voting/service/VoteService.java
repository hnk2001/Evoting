package com.election.voting.service;

import java.io.FileNotFoundException;
import java.util.Map;

import java.io.IOException;

public interface VoteService {

    public void castVote(String voterId, String aadhaarNumber, Long candidateId, Long electionId);
    
    Map<String, Long> getElectionResults(String electionName) throws IOException, FileNotFoundException;

}
