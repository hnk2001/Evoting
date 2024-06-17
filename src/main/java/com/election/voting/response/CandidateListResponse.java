package com.election.voting.response;
import java.util.List;

import com.election.voting.DTO.CandidateDTO;

public class CandidateListResponse {
    private List<CandidateDTO> candidates;

    public CandidateListResponse(List<CandidateDTO> candidates) {
        this.candidates = candidates;
    }

    public List<CandidateDTO> getCandidates() {
        return candidates;
    }

    public void setCandidates(List<CandidateDTO> candidates) {
        this.candidates = candidates;
    }
}

