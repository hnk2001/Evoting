package com.election.voting.DTO;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Setter
@Getter
@NoArgsConstructor
@AllArgsConstructor
public class VoterDTO {
    private String voterId;
    private String cityOrVillage;
    private String taluka;
    private String district;
    private String state;
    

}
