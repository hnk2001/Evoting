package com.election.voting.service.Impl;

import java.util.ArrayList;
import java.util.List;

import com.election.voting.DTO.AdminDTO;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

import com.election.voting.config.JwtProvider;
import com.election.voting.exception.AdminException;
import com.election.voting.model.Admin;
import com.election.voting.repository.AdminRepository;

@Service
public class AdminServiceImpl implements UserDetailsService{
    
    @Autowired
    private AdminRepository adminRepository;

    @Autowired
    private JwtProvider jwtProvider;

    @Override
    public UserDetails loadUserByUsername(String username) throws UsernameNotFoundException {
        Admin admin = adminRepository.findByUsername(username);
        if(admin == null){
            throw new UsernameNotFoundException("Admin not found with username : "+username);
        }
        List<GrantedAuthority> authorities = new ArrayList<>();
        return new org.springframework.security.core.userdetails.User(admin.getUsername(),admin.getPassword(),authorities);
    }

    
    public Admin findAdminProfileByJwt(String jwt) throws AdminException {
        String username = jwtProvider.getUsernameFromToken(jwt);

        Admin admin = adminRepository.findByUsername(username);

        if(admin == null){
            throw new AdminException("admin not found with username");
        }
        return admin;
    }

    public Admin findByEmail(String email) {
        return adminRepository.findByEmail(email);
    }

    public Admin updateAdmin(Admin admin) {
        return adminRepository.save(admin);
    }

    // Admin list
    public List<AdminDTO> getAllCandidates(Long id) {
        List<Admin> admins = adminRepository.findAdminByAdminId(id);
        List<AdminDTO> adminDTOS = new ArrayList<>();
        for (Admin admin : admins) {
            AdminDTO adminDTO = new AdminDTO();
            adminDTO.setId(admin.getId().toString());
            adminDTO.setFullName(admin.getFullName());
            adminDTO.setRole(admin.getRole().toString());
            adminDTOS.add(adminDTO);
        }
        return adminDTOS;
    }
}
