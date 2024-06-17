package com.election.voting.exception;

import lombok.Getter;
import lombok.Setter;

@Setter
@Getter
public class AdminException extends Exception{
    public AdminException(){}
    public AdminException(String message){
        super(message);
    }
}
