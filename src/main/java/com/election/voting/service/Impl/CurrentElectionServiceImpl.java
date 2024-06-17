package com.election.voting.service.Impl;

import com.election.voting.model.CurrentElection;
import com.election.voting.repository.CurrentElectionRepository;
import com.election.voting.service.CurrentElectionService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
public class CurrentElectionServiceImpl implements CurrentElectionService {
    @Autowired
    private CurrentElectionRepository currentElectionRepository;

    @Override
    public void castVote(String voterId, Long electionId) {
        CurrentElection currentElection = new CurrentElection();
        currentElection.setElectionId(electionId);
        currentElection.setVoterId(voterId);
        currentElectionRepository.save(currentElection);
    }
}
