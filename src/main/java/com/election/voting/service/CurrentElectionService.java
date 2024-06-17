package com.election.voting.service;

public interface CurrentElectionService {
    public void castVote(String voterId, Long electionId);
}
