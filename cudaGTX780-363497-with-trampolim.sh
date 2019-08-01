#!/bin/bash

sshpass -p uwnSDC6W ssh -f -N -T -X -L 2223:172.16.3.10:22 rag@dacom.cm.utfpr.edu.br -p 19680
ssh -p 2223 rag@localhost