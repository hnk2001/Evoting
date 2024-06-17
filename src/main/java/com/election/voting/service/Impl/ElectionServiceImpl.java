package com.election.voting.service.Impl;

import java.lang.reflect.Field;
import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.util.List;
import java.util.NoSuchElementException;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.election.voting.model.Admin;
import com.election.voting.model.AdminRole;
import com.election.voting.model.Election;
import com.election.voting.model.ElectionAssembly;
import com.election.voting.repository.ElectionRepository;
import com.election.voting.repository.VoterRepository;
import com.election.voting.response.ElectionResponse;
import com.election.voting.response.ElectionUpdateResponse;
import com.election.voting.service.ElectionService;

@Service
public class ElectionServiceImpl implements ElectionService {

    @Autowired
    ElectionRepository electionRepository;

    @Autowired
    VoterRepository voterRepository;

    @Override
    public List<Election> getAllElections() {
        return electionRepository.findAll();
    }

    @Override
    public Long getElectionIdByName(String name) {
        return electionRepository.findIdByName(name);
    }

    @Override
    public Election getElectionById(Long id) {
        return electionRepository.findById(id)
                .orElseThrow(() -> new NoSuchElementException("Election not found"));
    }

    @Override
    public ElectionResponse createElection(Election election, Admin admin) {
        try {
            if (admin.getRole() == AdminRole.CITY_NAGAR_ADHYAKSHA) {
                election.setAssembly(ElectionAssembly.NAGARADHYAKSHA);
            } else if (admin.getRole() == AdminRole.CITY_NAGAR_SEVAK) {
                election.setAssembly(ElectionAssembly.NAGARSEVAK);
            } else if (admin.getRole() == AdminRole.VILLAGE) {
                election.setAssembly(ElectionAssembly.GRAM_PANCHAYAT);
            }

            election.setCreatedAt(new Timestamp(System.currentTimeMillis()));
            Election createdElection = electionRepository.save(election);

            return new ElectionResponse(createdElection, "Election created successfully");
        } catch (Exception e) {
            return new ElectionResponse(null, "Failed to create election");
        }
    }

    @Override
    public ElectionUpdateResponse updateElection(Long electionId, Election updatedElection, Admin admin) {
        try {
            Optional<Election> existingElection = electionRepository.findById(electionId);
            if (existingElection.isPresent()) {
                Election currentElection = existingElection.get();

                LocalDateTime currentTime = LocalDateTime.now();
                LocalDateTime startTime = currentElection.getStartTime();

                Admin electionAdmin = currentElection.getAdmin();

                boolean flag = false;

                if (currentTime.isBefore(startTime)) {
                    flag = true;
                }

                // Check if the admin has access to update this election and also can not update when election is started
                if ((admin == electionAdmin) && (flag == true)) {
                    // Use reflection to update non-null fields of the current election with the new
                    // values
                    Field[] fields = Election.class.getDeclaredFields();
                    for (Field field : fields) {
                        field.setAccessible(true);
                        Object updatedValue = field.get(updatedElection);
                        if (updatedValue != null) {
                            field.set(currentElection, updatedValue);
                        }
                    }

                    currentElection.setUpdatedAt(new Timestamp(System.currentTimeMillis()));

                    Election updated = electionRepository.save(currentElection);
                    return new ElectionUpdateResponse(updated, "Election updated successfully");
                } else {
                    return new ElectionUpdateResponse(null, "You don't have access to update this election");
                }
            } else {
                return new ElectionUpdateResponse(null, "Election not found");
            }
        } catch (Exception e) {
            return new ElectionUpdateResponse(null, "Failed to update election");
        }
    }

    @Override
    public void deleteElection(String name, Admin admin) {
        try {
            Optional<Election> election = electionRepository.findByName(name);
            if (election.isPresent()) {
                Admin adminElection = election.get().getAdmin();
                LocalDateTime currentTime = LocalDateTime.now();
                LocalDateTime startTime = election.get().getStartTime();
                Long id = election.get().getId();
                if (adminElection == admin && currentTime.isBefore(startTime)) {
                    electionRepository.deleteById(id);
                }
            }
        } catch (Exception e) {
            System.out.println("eletction not found ");
        }
    }

    @Override
    public void enableElection(Long id, LocalDateTime startTime, LocalDateTime endTime) {
        Election election = electionRepository.findById(id)
                .orElseThrow(() -> new NoSuchElementException("Election not found"));
        election.setStartTime(startTime);
        election.setEndTime(endTime);
        electionRepository.save(election);
    }

    @Override
    public void disableElection(Long id) {
        Election election = electionRepository.findById(id)
                .orElseThrow(() -> new NoSuchElementException("Election not found"));
        election.setStartTime(null);
        election.setEndTime(null);
        electionRepository.save(election);
    }

    @Override
    public List<Election> getAllElectionsByAdminId(Long id){
        return electionRepository.findByAdminId(id);
    }
}


