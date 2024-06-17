package com.election.voting.service;

import java.time.LocalDateTime;
import java.util.List;

import com.election.voting.response.ElectionUpdateResponse;
import com.election.voting.model.Admin;
import com.election.voting.model.Election;
import com.election.voting.response.ElectionResponse;


public interface ElectionService {
    List<Election> getAllElections();

    Long getElectionIdByName(String name);

    Election getElectionById(Long id);

    ElectionResponse createElection(Election election, Admin admin) throws Exception;

    ElectionUpdateResponse updateElection(Long electionId, Election updatedElection, Admin admin);

    void deleteElection(String name, Admin admin);

    void enableElection(Long id, LocalDateTime startTime, LocalDateTime endTime);

    void disableElection(Long id);

    List<Election> getAllElectionsByAdminId(Long id);
}