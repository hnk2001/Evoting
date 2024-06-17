package com.election.voting.response;
import java.util.List;

import com.election.voting.DTO.AdminDTO;

public class AdminListResponse {
    private List<AdminDTO> admins;

    public AdminListResponse(List<AdminDTO> admins) {
        this.admins = admins;
    }

    public List<AdminDTO> getAdmins() {
        return admins;
    }

    public void setAdmins(List<AdminDTO> admins) {
        this.admins = admins;
    }
}

