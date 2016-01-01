      PROGRAM TEST
 
C THIS PROGRAM CONSISTS OF 64 NESTED DO LOOPS.  THEY ARE TIMED FOR
C WALL CLOCK TIME. THE MFLOPS ARE CALCULATED BY DIVIDING THE
C THE TOTAL NUMBER OF FLOATING POINT OPERATIONS BY THE WALLCLOCK TIME.
C SEVERAL VARIABLES HAVE BEEN EQUIVALENCED TO REDUCE MEMORY USAGE.
C RTC() RETURNS THE REAL-TIME CLOCK READING, ALLOWING US TO GET
C ACCURATE WALLCLOCK TIMES.
 
      PARAMETER (NCOMBS=9)
      PARAMETER (NDIM1=1000,NDIM2=100,NDIM3=10)
      PARAMETER (NSZ1=10,NSZ2=25,NSZ3=50)
      PARAMETER (NSZ4=100,NSZ5=250,NSZ6=500,NSZ7=750)
      DIMENSION SUBSCR(NCOMBS,3)
      INTEGER SUBSCR
      DATA (SUBSCR(1,I),I=1,3)/NSZ1,NSZ1,NDIM3/
      DATA (SUBSCR(2,I),I=1,3)/NSZ2,NSZ1,NDIM3/
      DATA (SUBSCR(3,I),I=1,3)/NSZ3,NSZ1,NDIM3/
      DATA (SUBSCR(4,I),I=1,3)/NSZ4,NSZ1,NDIM3/
      DATA (SUBSCR(5,I),I=1,3)/NSZ4,NDIM2,NDIM3/
      DATA (SUBSCR(6,I),I=1,3)/NSZ5,NDIM2,NDIM3/
      DATA (SUBSCR(7,I),I=1,3)/NSZ6,NDIM2,NDIM3/
      DATA (SUBSCR(8,I),I=1,3)/NSZ7,NDIM2,NDIM3/
      DATA (SUBSCR(9,I),I=1,3)/NDIM1,NDIM2,NDIM3/
 
      DO 200   I = 1,NCOMBS
        CALL CLOOPS(I,SUBSCR(I,1),SUBSCR(I,2),SUBSCR(I,3))
  200 CONTINUE

      STOP
      END

 
      SUBROUTINE CLOOPS(NCASE,NSIZE1,NSIZE2,NSIZE3)

      PARAMETER (CLOCK=6.0E-9)
      PARAMETER (NDIM1=1000,NDIM2=100,NDIM3=10)
      PARAMETER (NDIM4=32*NDIM1)
      PARAMETER (NDIM5=(NDIM1*NDIM2*NDIM3)+(NDIM1*NDIM2)+NDIM1)
      PARAMETER (NDIM6=2500)
      PARAMETER (NT1=4*NDIM1*NDIM2*NDIM3)
      PARAMETER (NT2=27*NDIM1*NDIM2)
      PARAMETER (NT3=(29*NDIM1)+(9*NDIM2)+(2*NDIM2*NDIM2))
      PARAMETER (NTOT=NT1+NT2+NT3+NDIM6)
 
      COMMON /WORK/ A2(NDIM1,NDIM2),B2(NDIM1,NDIM2),C2(NDIM1,NDIM2),
     +              D2(NDIM1,NDIM2),E2(NDIM1,NDIM2),F2(NDIM1,NDIM2),
     +              G2(NDIM1,NDIM2),DBLE22(NDIM1,NDIM2),
     +              CMPLX2(NDIM1,NDIM2),
     +              AR(NDIM1,NDIM2),AI(NDIM1,NDIM2),P2(3,NDIM1),
     +              G3(NDIM1,NDIM2,NDIM3),WR2(NDIM1,NDIM2),
     +              WR1(NDIM1,NDIM2),
     +              DR(3,NDIM2,NDIM1),GTEN(NDIM2,NDIM2),
     +              DBLE2(NDIM1,NDIM2),
     +              FTEMP(NDIM1,3),H3(NDIM1,NDIM2,NDIM3)

      COMMON /WORK/ Q6(NDIM1,NDIM2),
     +              B3(NDIM1,NDIM2,NDIM3),A3(NDIM1,NDIM2,NDIM3),
     +              A1(NDIM1),B1(NDIM1),F1(NDIM1),D1(NDIM1),
     +              INT2(NDIM1,NDIM2),I2(NDIM1,NDIM2),
     +              J2(NDIM1,NDIM2),K2(NDIM1,NDIM2),
     +              MB(NDIM2,NDIM2),C(NDIM1),ZERO(NDIM2),
     +              C11(NDIM6),JSAVE(NDIM1),GG(NDIM1,14),FZT(NDIM2,1),
     +              Q2(NDIM1,NDIM2),V(NDIM1,NDIM2),T2(NDIM2),
     +              UQ(NDIM2),DUQ(NDIM2),TQ(NDIM2),DTQ(NDIM2),AM(NDIM1),
     +              DSQ(NDIM1),SQ(NDIM1),FPP(NDIM2),FTP(NDIM2)
 
      DIMENSION F3(NDIM1,NDIM2,1)
      DIMENSION E3(NDIM1,NDIM2,10)
      DIMENSION F(NDIM1,5,NDIM2),E(NDIM1,NDIM2,5)
      DIMENSION E11(NDIM4),F11(NDIM4),D11(NDIM4)
      DIMENSION G11(NDIM4),H11(NDIM4),P11(NDIM4)
      DIMENSION A11(NDIM5),B11(NDIM5)
      DIMENSION D3(NDIM1,NDIM2,NDIM3),C3(NDIM1,NDIM2,NDIM3)
      DIMENSION X2(NDIM1,NDIM1),Y2(NDIM1,NDIM1),Z2(NDIM1,NDIM1)
      DIMENSION CMPLX3(NDIM1,NDIM2),CMPLX4(NDIM1,NDIM2)
      DIMENSION DUMMY1(NTOT)
 
      EQUIVALENCE (DUMMY1(1),A2(1,1))
      EQUIVALENCE (D3(1,1,1),A2(1,1)),(C3(1,1,1),AI(1,1))
      EQUIVALENCE (A11(1),D3(1,1,1)),(B11(1),P2(1,1))
      EQUIVALENCE (E11(1),A2(1,1)),(F11(1),B2(1,1))
      EQUIVALENCE (D11(1),C2(1,1)),(G11(1),D2(1,1))
      EQUIVALENCE (H11(1),E2(1,1)),(P11(1),F2(1,1))
      EQUIVALENCE (F(1,1,1),D3(1,1,1)),(E(1,1,1),B3(1,1,1))
      EQUIVALENCE (A2(1,1),F3(1,1,1))
      EQUIVALENCE (A2(1,1),E3(1,1,1))
      EQUIVALENCE (X2(1,1),A2(1,1)),(Y2(1,1),G3(1,1,1))
      EQUIVALENCE (CMPLX3(1,1),G3(1,1,1))
      EQUIVALENCE (CMPLX4(1,1),H3(1,1,1))
      EQUIVALENCE (Z2(1,1),H3(1,1,1))
 
      COMMON /BLK2/ TCT,TWT,TFLOPS
 
 
      INTEGER  TSTART, TLOOPS(100), FLOOPS(100)
      REAL MFLOPS
      DOUBLE PRECISION DBLE2,DBLE22
      COMPLEX CMPLX2,CMPLX3,CMPLX4,CMP1(NDIM1),CMP2

 
      PI = 3.141592653589793
      PRINT 10,  NCASE,NSIZE1,NSIZE2,NSIZE3
      DO 500   I = 1,NTOT
        DUMMY1(I) = 0
  500 CONTINUE
 
      DO 520   I = 1,NSIZE1
        JSAVE(I) = 100
  520 CONTINUE

      M1 = 1
      DO 580  I = 1,NSIZE1
        DO 560   J = 1,NSIZE2
          INT2(I,J) = M1
          M1 = M1+1
          IF (M1 .EQ. 5)  M1 = 1
  560   CONTINUE
  580 CONTINUE

      TCT = 0
      TWT = 0
      TFLOPS = 0
      NLOOPS = 1
 
 
C ------------------------------------------------------------------------------
      TSTART = RTC()
      DO 1000   I = 1,NSIZE2
        DO 950   J = 1,NSIZE1
          A2(J,I) = A2(J,I) + 1
          IF (A2(J,I) .EQ. 0) GO TO 1000
  950   CONTINUE
 1000 CONTINUE
      TLOOPS(NLOOPS) = RTC()-TSTART
      FLOOPS(NLOOPS) = NSIZE1*NSIZE2
      NLOOPS = NLOOPS+1
 
C ------------------------------------------------------------------------------
      TSTART = RTC()
      DO 1100 I = 1,NSIZE1
        DO 1030 J = 1,NSIZE1
          X2(I,J) = 0.0
 1030   CONTINUE
        DO 1070 K = 1,NSIZE1
          DO 1050 J = 1,NSIZE1
            X2(I,J) = X2(I,J)+Y2(I,K)*Z2(K,J)
 1050     CONTINUE
 1070   CONTINUE
 1100 CONTINUE
      TLOOPS(NLOOPS) = RTC()-TSTART
      FLOOPS(NLOOPS) = (NSIZE1*NSIZE1*NSIZE1*2)
      NLOOPS = NLOOPS+1
 
 
      DO 1140   I = 1,NSIZE2
        DO 1120   J = 1,NSIZE1
          C2(J,I) = 0.2
          D2(J,I) = 0.1
          B2(J,I) = 0.01
 1120   CONTINUE
 1140 CONTINUE
      S = .0001

C ------------------------------------------------------------------------------
      TSTART = RTC()
      DO 1200   I = 1,NSIZE2
        DO 1150   J = 1,NSIZE1
          A2(J,I) = S
          B2(J,I) = (C2(J,I)+D2(J,I))*S
          S = B2(J,I) + C2(J,I)
 1150   CONTINUE
 1200 CONTINUE
      TLOOPS(NLOOPS) = RTC()-TSTART
      FLOOPS(NLOOPS) = 3*NSIZE1*NSIZE2
      NLOOPS = NLOOPS+1
 
C ------------------------------------------------------------------------------
      TSTART = RTC()
      DO 1300   J = 1,NSIZE1
        DO 1250   I = 1,NSIZE1
          X2(I,J) = Y2(I,J)
          Y2(I,J) = X2(I,J)*Z2(I,J)
 1250   CONTINUE
 1300 CONTINUE
      TLOOPS(NLOOPS) = RTC()-TSTART
      FLOOPS(NLOOPS) = NSIZE1*NSIZE2
      NLOOPS = NLOOPS+1
 
C ------------------------------------------------------------------------------
      TSTART = RTC()
      DO 1400   J = 2,NSIZE2
        DO 1380   K = 1,NSIZE3
          DO 1360   I = 1, NSIZE1
            D3(I,J,K) = (A3(I,J-1,K)+C3(I,J,K))*AI(J,K) + 
     1         (H3(I,J-1,K)+G3(I,J,K))*WR2(J,K)
            B3(I,J,K) = V(I,J)*V(J,K) - A3(I,J,K)*V(I,J) -
     1         H3(I,J,K)*V(I,J)
 1340       CONTINUE
 1360     CONTINUE
          D3(I,NSIZE2,K)=(A3(I,NSIZE2,K)+C3(I,NSIZE2,K))*
     1       AI(NSIZE2,K)+(H3(I,NSIZE2,K)+G3(I,NSIZE2,K))*
     2       WR2(NSIZE2,K)
 1380   CONTINUE
 1400 CONTINUE
      TLOOPS(NLOOPS) = RTC()-TSTART
      FLOOPS(NLOOPS) = ((NSIZE2-1)*NSIZE3*NSIZE1*10)+
     1   ((NSIZE2-1)*5*NSIZE3)
      NLOOPS = NLOOPS+1
 
C ------------------------------------------------------------------------------
      TSTART = RTC()
      DO 1500   J = 2,NSIZE2
        DO 1450   I = 2,NSIZE1
          A2(I,J) = .5*((E(I,J,1)-E(I-1,J-1,1))*(E(I-1,J,2)-E(I,J-1,2))-
     1       (E(I,J,2)-E(I-1,J-1,2))*(E(I-1,J,1)-E(I,J-1,1)))
 1450   CONTINUE
        A2(1,J) = A2(NSIZE1,J)
        A2(NSIZE1,J) = A2(2,J)
 1500 CONTINUE
      TLOOPS(NLOOPS) = RTC()-TSTART
      FLOOPS(NLOOPS) = (NSIZE1-1)*(NSIZE2-1)*8
      NLOOPS = NLOOPS+1
 
      JMAX = NSIZE2-2
      IMAX = NSIZE1-2
C ------------------------------------------------------------------------------
      TSTART = RTC()
      DO 1600 L = 1,JMAX + 1
        DO 1550   K = 1,IMAX + 1
          I = K
          J = L
          A2(I,L) = B2(I,J+1) - B2(I,J)
          C2(I,L) = D2(I,J+1) - D2(I,J)
          E2(K,J) = B2(I+1,J) - B2(I,J)
          F2(K,J) = D2(I+1,J) - D2(I,J)
 1550   CONTINUE
 1600 CONTINUE
      TLOOPS(NLOOPS) = RTC()-TSTART
      FLOOPS(NLOOPS) = (JMAX+1)*(IMAX+1)*4
      NLOOPS = NLOOPS+1
 
C ------------------------------------------------------------------------------
      TSTART = RTC()
      DO 1700   I = 1,NSIZE2
        DO 1440   J = 1,NSIZE1
          A2(J,I) = B2(J,I) + C2(J,I)
 1440   CONTINUE
 1700 CONTINUE
      TLOOPS(NLOOPS) = RTC()-TSTART
      FLOOPS(NLOOPS) = NSIZE1*NSIZE2
      NLOOPS = NLOOPS+1
 
C ------------------------------------------------------------------------------
      TSTART = RTC()
      S1 = 2.5
      DO 1800   I = 1,NSIZE2
        DO 1750   J = 1,NSIZE1
          A2(J,I) = B2(J,I) + S1*C2(J,I)
 1750   CONTINUE
 1800 CONTINUE
      TLOOPS(NLOOPS) = RTC()-TSTART
      FLOOPS(NLOOPS) = 2*NSIZE1*NSIZE2
      NLOOPS = NLOOPS+1
 
C ------------------------------------------------------------------------------
      TSTART = RTC()
      DO 1900   I = 1,NSIZE2
        DO 1850   J = 1,NSIZE1
          A2(J,I) = B2(J,I) + D1(I)*C2(J,I)
 1850   CONTINUE
 1900 CONTINUE
      TLOOPS(NLOOPS) = RTC()-TSTART
      FLOOPS(NLOOPS) = 2*NSIZE1*NSIZE2
      NLOOPS = NLOOPS+1
 
 
C ------------------------------------------------------------------------------
      TSTART = RTC()
      DO 2000   I = 1,NSIZE2
        DO 1950   J = 1,NSIZE1
          A2(J,I) = B2(J,I) + C2(J,I)
          B2(J,I) = A2(J,I) + D2(J,I)
 1950 CONTINUE
 2000 CONTINUE
      TLOOPS(NLOOPS) = RTC()-TSTART
      FLOOPS(NLOOPS) = 2*NSIZE1*NSIZE2
      NLOOPS = NLOOPS+1
 
C ------------------------------------------------------------------------------
      TSTART = RTC()
      DO 2100   I = 1,NSIZE2
        DO 2050   J = 1,NSIZE1
          A06 = B2(J,I) + C2(J,I)
          A2(J,I) = A06*D2(J,I)
 2050   CONTINUE
 2100 CONTINUE
      TLOOPS(NLOOPS) = RTC()-TSTART
      FLOOPS(NLOOPS) = 2*NSIZE1*NSIZE2
      NLOOPS = NLOOPS+1
 
C ------------------------------------------------------------------------------
      TSTART = RTC()
      DO 2200   I = 1,NSIZE2
        DO 2150   J = 1,NSIZE1
          A1(I) = B2(J,I) + C2(J,I)
          A2(J,I) = A1(I)*D2(J,I)
 2150   CONTINUE
 2200 CONTINUE
      TLOOPS(NLOOPS) = RTC()-TSTART
      FLOOPS(NLOOPS) = 2*NSIZE1*NSIZE2
      NLOOPS = NLOOPS+1
 
 
C ------------------------------------------------------------------------------
      TSTART = RTC()
      DO 2300   I = 1,NSIZE2
        DO 2250   J = 1,NSIZE1
          A1(I) = B2(J,I) + C2(J,I)
          A2(J,I) = A1(I)*D2(J,I)
          B1(J) = E2(J,I) + F2(J,I)
          B2(J,I) = B1(J)*G2(J,I)
 2250   CONTINUE
 2300 CONTINUE
      TLOOPS(NLOOPS) = RTC()-TSTART
      FLOOPS(NLOOPS) = 4*NSIZE1*NSIZE2
      NLOOPS = NLOOPS+1

      DO 2320   I = 1,NSIZE2
        DO 2310   J = 1,NSIZE1
          E2(J,I) = 1.0
          D2(J,I) = PI
 2310   CONTINUE
 2320 CONTINUE
C ------------------------------------------------------------------------------
      TSTART = RTC()
      DO 2400   I = 1,NSIZE2
        DO 2350   J = 1,NSIZE1
          A2(J,I) = SQRT(D2(J,I))
          B2(J,I) = ABS(D2(J,I))
          C2(J,I) = MOD(D2(J,I),E2(J,I))
          G2(J,I) = EXP(D2(J,I))
          E2(J,I) = ALOG(D2(J,I))
          F2(J,I) = ALOG10(D2(J,I))
 2350   CONTINUE
 2400 CONTINUE
      TLOOPS(NLOOPS) = RTC()-TSTART
      FLOOPS(NLOOPS) = 113*NSIZE1*NSIZE2
      NLOOPS = NLOOPS+1
 
C ------------------------------------------------------------------------------
      TSTART = RTC()
      DO 2500   I = 1,NSIZE2
        DO 2450   J = 1,NSIZE1
          A2(J,I) = FLOAT(INT2(J,I))
          B2(J,I) = REAL(D2(J,I))
          C2(J,I) = SNGL(DBLE2(J,I))
          I2(J,I) = INT(D2(J,I))
          J2(J,I) = IFIX(D2(J,I))
          K2(J,I) = IDINT(DBLE2(J,I))
          E2(J,I) = DBLE(D2(J,I))
          F2(J,I) = CMPLX(D2(J,I),B2(J,I))
 2450   CONTINUE
 2500 CONTINUE
      TLOOPS(NLOOPS) = RTC()-TSTART
      FLOOPS(NLOOPS) = 3*NSIZE1*NSIZE2
      NLOOPS = NLOOPS+1
 
C ------------------------------------------------------------------------------
      TSTART = RTC()
      DO 2600   I = 2, NSIZE1
        DO 2550   J = 2, NSIZE2
          A2(I,J) = B2(I,J) + C2(I,J) + D2(I,J) + E2(I,J) - F2(I,J)
 2550   CONTINUE
 2600 CONTINUE
      TLOOPS(NLOOPS) = RTC()-TSTART
      FLOOPS(NLOOPS) = 4*NSIZE1*NSIZE2
      NLOOPS = NLOOPS+1
 
C ------------------------------------------------------------------------------
      TSTART = RTC()
      DO 2700   J = 1,NSIZE2
        DO 2650   I = 1,NSIZE1
          A2(I,J) = B2(I,J) + PI*(C2(I,J)-2.*B2(I,J)+A2(I,J))
          D2(I,J) = E2(I,J) + PI*(F2(I,J)-2.*E2(I,J)+D2(I,J))
          AR(I,J) = G2(I,J) + PI*(AI(I,J)-2.*G2(I,J)+AR(I,J))
          B2(I,J) = C2(I,J)
          E2(I,J) = F2(I,J)
          G2(I,J) = AI(I,J)
 2650   CONTINUE
 2700 CONTINUE
      TLOOPS(NLOOPS) = RTC()-TSTART
      FLOOPS(NLOOPS) = 15*NSIZE1*NSIZE2
      NLOOPS = NLOOPS+1
 
C ------------------------------------------------------------------------------
      TSTART = RTC()
      DO 2800   K = 2,NSIZE2
        DO 2750   I = 1,NSIZE1-1
          C2(I,K) = A2(I+1,K-1) + A2(I+1,K) - B2(I,K-1) - B2(I,K)
          D2(I,K) = A2(I,K-1) + A2(I,K) - B2(I+1,K-1) - B2(I+1,K)
          AI(I,K) = (C2(I,K)-D2(I,K))*PI*F1(K)
          G2(I,K) = (C2(I,K)+D2(I,K))*PI*F1(K)
          AI(I,K) = AI(I,K-1) + AI(I,K)
          G2(I,K) = G2(I,K-1) + G2(I,K)
 2750   CONTINUE
 2800 CONTINUE
      TLOOPS(NLOOPS) = RTC()-TSTART
      FLOOPS(NLOOPS) = 14*NSIZE1*NSIZE2
      NLOOPS = NLOOPS+1
 
 
      DO 2820   I = 1,NSIZE2
        DO 2810   J = 1,NSIZE1
          CMPLX2(J,I) = (0.1,0.)
 2810   CONTINUE
 2820 CONTINUE
C ------------------------------------------------------------------------------
      TSTART = RTC()
      DO 2900   I = 1,NSIZE2
        DO 2850   J = 1,NSIZE1
          A2(J,I) = CABS(CMPLX2(J,I))
          B2(J,I) = CSIN(CMPLX2(J,I))
          B2(J,I) = CCOS(CMPLX2(J,I))
          B2(J,I) = CSQRT(CMPLX2(J,I))
          B2(J,I) = CEXP(CMPLX2(J,I))
          B2(J,I) = CLOG(CMPLX2(J,I))
 2850   CONTINUE
 2900 CONTINUE
      TLOOPS(NLOOPS) = RTC()-TSTART
C  "133" FROM HARDWARE PERFORMANCE MONITOR FOR THIS SPECIFIC DATA CASE
      FLOOPS(NLOOPS) = 133*NSIZE1*NSIZE2
      NLOOPS = NLOOPS+1
 
      DO 2920   I = 1,NSIZE2
        DO 2910   J = 1,NSIZE1
          B2(J,I) = PI
 2910   CONTINUE
 2920 CONTINUE
C ------------------------------------------------------------------------------
      TSTART = RTC()
      DO 3000   I = 1,NSIZE2
        DO 2950   J = 1,NSIZE1
          IF (B2(J,I) .NE. 0.0) A2(J,I) = C2(J,I)*D2(J,I)
 2950   CONTINUE
 3000 CONTINUE
      TLOOPS(NLOOPS) = RTC()-TSTART
      FLOOPS(NLOOPS) = NSIZE1*NSIZE2
      NLOOPS = NLOOPS+1
 
C ------------------------------------------------------------------------------
      TSTART = RTC()
      DO 3100   I = 1,NSIZE2
        DO 3050   J = 1,NSIZE1
          IF (B2(J,I) .NE. 0.0) THEN
             A2(J,I) = C2(J,I)*B2(J,I)
          ELSE
             B2(J,I) = C2(J,I)*A2(J,I)
          ENDIF
 3050   CONTINUE
 3100 CONTINUE
      TLOOPS(NLOOPS) = RTC()-TSTART
      FLOOPS(NLOOPS) = NSIZE1*NSIZE2
      NLOOPS = NLOOPS+1
 
C ------------------------------------------------------------------------------
      TSTART = RTC()
      DO 3200   I = 1,NSIZE2
        DO 3170   J = 1,NSIZE1
          IF (B2(J,I) .EQ. 0.0)   GO TO 3130
          A2(J,I) = C2(J,I)*B2(J,I)
          GO TO 3170
 3130     CONTINUE
          B2(J,I) = C2(J,I)*A2(J,I)
 3170   CONTINUE
 3200 CONTINUE
      TLOOPS(NLOOPS) = RTC()-TSTART
      FLOOPS(NLOOPS) = NSIZE1*NSIZE2
      NLOOPS = NLOOPS+1
C ------------------------------------------------------------------------------
      TSTART = RTC()
      DO 3300   I = 1,NSIZE2
        DO 3270   J = 1,NSIZE1
          A2(J,I) = C2(J,I)
          IF (B2(J,I) .GE. 0)   GO TO 3230
          B2(J,I) = C2(J,I)*A2(J,I)
          GO TO 3270
 3230     CONTINUE
          C2(J,I) = C2(J,I)*A2(J,I)
 3270   CONTINUE
 3300 CONTINUE
      TLOOPS(NLOOPS) = RTC()-TSTART
      FLOOPS(NLOOPS) = NSIZE1*NSIZE2
      NLOOPS = NLOOPS+1
 
C ------------------------------------------------------------------------------
      TSTART = RTC()
      DO 3400 K = 1,NSIZE2
        DO 3330 I = 1,NSIZE1
          CMPLX2(I,K) = 0.0
 3330   CONTINUE
        DO 3370 J = 1,NSIZE2
          DO 3350 I = 1,NSIZE1
            CMPLX2(I,K) = CMPLX2(I,K)+CMPLX3(I,J)*CMPLX4(J,K)
 3350     CONTINUE
 3370   CONTINUE
 3400 CONTINUE
      TLOOPS(NLOOPS) = RTC()-TSTART
      FLOOPS(NLOOPS) = (NSIZE1*NSIZE2*NSIZE2*(2+6))
      NLOOPS = NLOOPS+1

C ------------------------------------------------------------------------------
      TSTART = RTC()
      DO 3500   I = 1,NSIZE2
        DO 3450   J = 1,NSIZE1
          IF (B2(J,I) .EQ. 0.0) THEN
             A2(J,I) = C2(J,I) + A2(J,I)
          ELSE IF (B2(J,I) .GT. 0.0) THEN
             B2(J,I) = C2(J,I) + B2(J,I)
          ELSE IF (C2(J,I) .GT. 0.0) THEN
             C2(J,I) = C2(J,I)*A2(J,I)
          ELSE
             D2(J,I) = C2(J,I)*A2(J,I)
          ENDIF
 3450   CONTINUE
 3500 CONTINUE
      TLOOPS(NLOOPS) = RTC()-TSTART
      FLOOPS(NLOOPS) = NSIZE1*NSIZE2
      NLOOPS = NLOOPS+1
 
C ------------------------------------------------------------------------------
      TSTART = RTC()
      DO 3600   I = 1,NSIZE2
        DO 3550   J = 1,NSIZE1
          IF (B2(J,I) .EQ. 0.0) THEN
             A2(J,I) = C2(J,I) + A2(J,I)
             IF (D2(J,I) .GT. 0.0) THEN
                B2(J,I) = C2(J,I)*A2(J,I)
             ELSE
                C2(J,I) = C2(J,I) + A2(J,I)
             ENDIF
          ELSE
             D2(J,I) = C2(J,I)*A2(J,I)
          ENDIF
 3550   CONTINUE
 3600 CONTINUE
      TLOOPS(NLOOPS) = RTC()-TSTART
      FLOOPS(NLOOPS) = NSIZE1*NSIZE2
      NLOOPS = NLOOPS+1
 
C ------------------------------------------------------------------------------
      TSTART = RTC()
      DO 3700   I = 1,NSIZE2
        DO 3680   J = 1,NSIZE1
          GO TO (3630,3640,3650,3660) INT2(J,I)
          A2(J,I) = A2(J,I) + B2(J,I)
 3630     CONTINUE
          B2(J,I) = B2(J,I) + C2(J,I)
 3640     CONTINUE
          C2(J,I) = C2(J,I) + D2(J,I)
 3650     CONTINUE
          D2(J,I) = D2(J,I) + A2(J,I)
 3660     CONTINUE
          E2(J,I) = D2(J,I) + B2(J,I)
 3680   CONTINUE
 3700 CONTINUE
      TLOOPS(NLOOPS) = RTC()-TSTART
      FLOOPS(NLOOPS) = NSIZE1*NSIZE2*2.5
      NLOOPS = NLOOPS+1
 
C ------------------------------------------------------------------------------
      TSTART = RTC()
      DO 3800   I = 1,NSIZE2
        DO 3750   J = 1,NSIZE1
          ITEST = INT2(J,I)
          IF (ITEST.LE.0 .OR. ITEST.GT.4) A2(J,I) = A2(J,I)*B2(J,I)
          IF (ITEST.LE.1 .OR. ITEST.GT.4) B2(J,I) = A2(J,I)*C2(J,I)
          IF (ITEST.LE.2 .OR. ITEST.GT.4) C2(J,I) = A2(J,I) + B2(J,I)
          IF (ITEST.LE.3 .OR. ITEST.GT.4) D2(J,I) = A2(J,I) + C2(J,I)
          E2(J,I) = A2(J,I)*PI + C2(J,I)*PI
 3750   CONTINUE
 3800 CONTINUE
      TLOOPS(NLOOPS) = RTC()-TSTART
      FLOOPS(NLOOPS) = NSIZE1*NSIZE2*4.5
      NLOOPS = NLOOPS+1
 
C ------------------------------------------------------------------------------
      TSTART = RTC()
      DO 3900   I = 1,NSIZE2
        DO 3880   J = 1,NSIZE1
          ASSIGN 3820 TO ILBL
          A2(J,I) = A2(J,I)*B2(J,I)
          IF (C2(J,I) .NE. 0.0) THEN
             ASSIGN 3850 TO ILBL
             B2(J,I) = B2(J,I)*C2(J,I)
          ENDIF
          GO TO ILBL
 3820     CONTINUE
          C2(J,I) = C2(J,I)*D2(J,I)
          GO TO 3880
 3850     CONTINUE
          D2(J,I) = D2(J,I)*E2(J,I)
 3880   CONTINUE
 3900 CONTINUE
      TLOOPS(NLOOPS) = RTC()-TSTART
      FLOOPS(NLOOPS) = 2.5*NSIZE1*NSIZE2
      NLOOPS = NLOOPS+1
 
C ------------------------------------------------------------------------------
      TSTART = RTC()
      DO 4000   I = 1,NSIZE2
        DO 3930   J = 1,NSIZE1
          A1(J) = D2(J,I) + A2(J,I)
 3930   CONTINUE
        DO 3970   J = 2,NSIZE1-1
          B2(J,I) = A1(J)*B2(J,I)
 3970   CONTINUE
 4000 CONTINUE
      TLOOPS(NLOOPS) = RTC()-TSTART
      FLOOPS(NLOOPS) = NSIZE1*NSIZE2 + (NSIZE1-2)*NSIZE2
      NLOOPS = NLOOPS+1
 
C ------------------------------------------------------------------------------
      TSTART = RTC()
      DO 4100   I = 1,NSIZE2
        DO 4050   J = 2,NSIZE1
          A2(J,I) = A2(J,I) - A2(J-1,I)*.99999
 4050   CONTINUE
 4100 CONTINUE
      TLOOPS(NLOOPS) = RTC()-TSTART
      FLOOPS(NLOOPS) = NSIZE2*(NSIZE1-1)*2
      NLOOPS = NLOOPS+1

      DO 4120   I = 1,NSIZE2
        DO 4110   J = 1,NSIZE1
          C2(J,I) = 0
          B2(J,I) = 0
          D2(J,I) = 0
 4110   CONTINUE
 4120 CONTINUE
C ------------------------------------------------------------------------------
      TSTART = RTC()
      DO 4200   I = 1,NSIZE2
        A1(1) = 1.0
        DO 4140   J = 2, NSIZE1
          A1(J) = C2(J,I) - A1(J-1)*B2(J,I)
 4140   CONTINUE
        DO 4170   J = 1,NSIZE1
          B2(J,I) = D2(J,I)*A1(J)
 4170   CONTINUE
 4200 CONTINUE
      TLOOPS(NLOOPS) = RTC()-TSTART
      FLOOPS(NLOOPS) = NSIZE2*(NSIZE1-1)*2 + NSIZE1
      NLOOPS = NLOOPS+1
 
C ------------------------------------------------------------------------------
      TSTART = RTC()
      DO 4300   I = 1,NSIZE2
        IF (I .EQ. 1) THEN
           DO 4230   J = 1,NSIZE1
             A2(J,I) = A2(J,I) + A2(J,NSIZE2)/2.0
 4230      CONTINUE
        ELSE
           DO 4270   J = 1,NSIZE1
             A2(J,I) = D2(J,I)*A2(J,I)
 4270      CONTINUE
        ENDIF
 4300 CONTINUE
      TLOOPS(NLOOPS) = RTC()-TSTART
      FLOOPS(NLOOPS) = (NSIZE2-1)*NSIZE1 + NSIZE1*2
      NLOOPS = NLOOPS+1
 
C ------------------------------------------------------------------------------
      TSTART = RTC()
      DO 4400   I = 1,NSIZE2, 4
        DO 4350   J = 1,NSIZE1
          A2(J,I) = A2(J,I) + D2(J,I)
          A2(J,I+1) = A2(J,I+1) + D2(J,I+1)
          A2(J,I+2) = A2(J,I+2) + D2(J,I+2)
          A2(J,I+3) = A2(J,I+3) + D2(J,I+3)
 4350   CONTINUE
 4400 CONTINUE
      TLOOPS(NLOOPS) = RTC()-TSTART
      FLOOPS(NLOOPS) = 4*(NSIZE2/4)*NSIZE1
      NLOOPS = NLOOPS+1
 
C ------------------------------------------------------------------------------
      TSTART = RTC()
      DO 4500   I = 1,NSIZE2,2
        DO 4450   J = 1,NSIZE1
          A2(J,I) = A2(J,I) + D2(J,I)
          A2(J,I+1) = A2(J,I+1) + A2(J,I)*C2(J,I)
 4450   CONTINUE
 4500 CONTINUE
      TLOOPS(NLOOPS) = RTC()-TSTART
      FLOOPS(NLOOPS) = ((NSIZE2+1)/2)*NSIZE1*3
      NLOOPS = NLOOPS+1
 
      NM2 = NSIZE2/2
C ------------------------------------------------------------------------------
      TSTART = RTC()
      DO 4600   I = 1,NM2
        DO 4550   J = 1,NSIZE1
          A2(J,I) = A2(J,I)*A2(J,I+NM2)
 4550   CONTINUE
 4600 CONTINUE
      TLOOPS(NLOOPS) = RTC()-TSTART
      FLOOPS(NLOOPS) = NM2*NSIZE1
      NLOOPS = NLOOPS+1
 
      T1 = 8.4
      XL = 5.
      TM = 4.5
C ------------------------------------------------------------------------------
      TSTART = RTC()
      DO 4700   K = 1,NSIZE2
        XU = ZERO(K)/T1
        A = .5*(XU+XL)
        BB = XU - XL
        DO 4650   II = 1,NSIZE1
          ADD = BB*C(II)
          X = A + ADD
          IY = X*SQRT(TM)
          IF (IY.GT.100 .OR. IY.LT.1) IY = 100
          F3(II,K,1) = MB(IY,K)
          X = A - ADD
          IY = X*SQRT(TM)
          IF (IY.GT.100 .OR. IY.LT.1) IY = 100
          F3(II,K,1) = MB(IY,K)
 4650   CONTINUE
        XL = XU
 4700 CONTINUE
 
      TLOOPS(NLOOPS) = RTC()-TSTART
      FLOOPS(NLOOPS) = 4*NSIZE2 + 5*NSIZE1*NSIZE2
      NLOOPS = NLOOPS+1

      FACT = 2.5
      EXJ = 2.1
      NSKIP = 2
      MSKIP = 2
      I2KS = 10
C ------------------------------------------------------------------------------
      TSTART = RTC()
      DO 4800 JJ = 1,NSIZE2
        DO 4750 MM = 1,NSIZE1
          JS = (JJ+MM)*2 - 3
          H = C11(JS) - C11(JS+10)
          C11(JS) = (C11(JS)+C11(JS+10))*FACT
          C11(JS+10) = (H*EXJ)*FACT
 4750   CONTINUE
 4800 CONTINUE
      TLOOPS(NLOOPS) = RTC()-TSTART
      FLOOPS(NLOOPS) = 5*NSIZE1*NSIZE2
      NLOOPS = NLOOPS+1

      IWO0 = 100
      IW10 = 100
      IW20 = 100
      NATOMS = 5
      IDCPU = 1
      C2Z = 3.49
      C1 = 1.13
C ------------------------------------------------------------------------------
      TSTART = RTC()
      DO 4900   JS = 1,NSIZE1
        J = JSAVE(JS)
        JW1 = 95 + J*5
        JWO = 95 + J*5
        JW2 = 95 + J*5
 
        G110 = GG(JS,10) + GG(JS,1)*C1
        G23 = GG(JS,2) + GG(JS,3)
        G45 = GG(JS,4) + GG(JS,5)
        FTEMP(JS,1) = G110 + GG(JS,11) + GG(JS,12) + C1*G23
        TT1 = GG(JS,1)*C2Z
        TT = G23*C2Z + TT1
        FTEMP(JS,2) = GG(JS,6) + GG(JS,7) + GG(JS,13) + TT + GG(JS,4)
        FTEMP(JS,3) = GG(JS,8) + GG(JS,9) + GG(JS,14) + TT + GG(JS,5)
        TT = G45*C2Z + TT1
        FZT(JWO,1) = FZT(JWO,1)-G110-GG(JS,13)-GG(JS,14)-C1*G45
        FZT(JW1,1)= FZT(JW1,1)-GG(JS,6)-GG(JS,8)-GG(JS,11)-TT-GG(JS,2)
        FZT(JW2,1)= FZT(JW2,1)-GG(JS,7)-GG(JS,9)-GG(JS,12)-TT-GG(JS,3)
 4900 CONTINUE
      TLOOPS(NLOOPS) = RTC()-TSTART
      FLOOPS(NLOOPS) = 39*NSIZE1
      NLOOPS = NLOOPS+1
 
C ------------------------------------------------------------------------------
      TSTART = RTC()
      DO 5000   I = 2,NSIZE2
        L = I-1
        H = A2(I,I)
        DO 4970   J = 1,NSIZE2
          S = 0.0E0
          SI = 0.0E0
          DO 4920   K = 1,NSIZE1
            S = S + B2(K,I)*C2(K,J) - A2(K,I)*D2(K,J)
            SI = SI + B2(K,I)*D2(K,J) + A2(K,I)*C2(K,J)
 4920     CONTINUE
          S = S*H
          SI = SI*H
          DO 4950   K = 1,NSIZE1
            C2(K,J) = C2(K,J) + S*B2(K,I) - SI*A2(K,I)
            D2(K,J) = D2(K,J) - SI*B2(K,I) + S*A2(K,I)
 4950     CONTINUE
 4970   CONTINUE
 5000 CONTINUE
      TLOOPS(NLOOPS) = RTC()-TSTART
      FLOOPS(NLOOPS) = (NSIZE2-1)*NSIZE2*16*NSIZE1
      NLOOPS = NLOOPS+1
 
      EPS2 = 2.25
      EPS4 = 3.75
C ------------------------------------------------------------------------------
      TSTART = RTC()
      DO 5100   J = 1,NSIZE2
        DO 5050   K = 2,NSIZE1
          FIL = H3(K,J,1)*Q6(K,J) + H3(K,J,1)*Q6(K,J)
          G32 = EPS2*G3(K,J,1)*FIL
          G34 = EPS4*FIL
          C2(K,J) = G32*WR1(K,J) - G34*WR2(K,J)
 5050   CONTINUE
 5100 CONTINUE
      TLOOPS(NLOOPS) = RTC()-TSTART
      FLOOPS(NLOOPS) = 9*NSIZE1*NSIZE2
      NLOOPS = NLOOPS+1
 
      P = PI
      R = PI
      S = PI
      ZC = PI
C ------------------------------------------------------------------------------
      TSTART = RTC()
      DO 5200   II = 1,NSIZE2
        S2 = S
        G = ZC*A1(II)
        H = ZC*P
        A1(II) = S*R
        S = A1(II)/R
        ZC = P/R
        P = ZC*B1(II) - S*G
        B1(II) = H + S*(ZC*G+S*B1(II))
        DO 5150   K = 1,NSIZE1
          H = A2(K,II)
          A2(K,II) = S*A2(K,II) + ZC*H
          A2(K,II) = ZC*A2(K,II) - S*H
 5150   CONTINUE
 5200 CONTINUE
      TLOOPS(NLOOPS) = RTC()-TSTART
      FLOOPS(NLOOPS) = 13*NSIZE2 + 6*NSIZE1*NSIZE2
      NLOOPS = NLOOPS+1
 
      H = PI
      ZZ = 0
C ------------------------------------------------------------------------------
      TSTART = RTC()
      DO 5300   I = 1,NSIZE2
        DO 5270   J = 1,NSIZE2
          G = 0.0E0
          GI = 0.0E0

          DO 5230   K = 1,NSIZE1
            G = G + A2(K,J)*A2(K,I) + B2(K,J)*B2(K,I)
            GI = GI - A2(K,J)*B2(K,I) + B2(K,J)*A2(K,I)
 5230     CONTINUE
          A1(I) = G/PI
          F1(I) = GI/PI
          ZZ = ZZ + A1(I)*D1(I) - F1(I)*B1(I)
 5270   CONTINUE
 5300 CONTINUE
      TLOOPS(NLOOPS) = RTC()-TSTART
      FLOOPS(NLOOPS) = 8*NSIZE2*NSIZE1*NSIZE2 + 6*NSIZE2*NSIZE2
      NLOOPS = NLOOPS+1

      HH = PI
      Z = PI
      FI = PI
      DO 5320   I = 1,NSIZE2
        DO 5310   J = 1,NSIZE1
          AR(J,I) = 0
          AI(J,I) = 0
 5310   CONTINUE
 5320 CONTINUE
C ------------------------------------------------------------------------------
      TSTART = RTC()
      DO 5400   I = 1,NSIZE2
        DO 5370   J = 1,NSIZE2
          G = A1(J) - HH*Z
          GI = P2(2,J) - HH*FI
          DO 5340   K = 1,NSIZE1
            AR(K,I)=HH-Z*A1(K)-G*AR(K,I)+FI*P2(2,K)+GI*AI(K,I)
            AI(K,I)=HH-Z*P2(2,K)-G*AI(K,I)-FI*A1(K)-GI*AR(K,I)
 5340     CONTINUE
 5370   CONTINUE
 5400 CONTINUE
      TLOOPS(NLOOPS) = RTC()-TSTART
      FLOOPS(NLOOPS) = 4*NSIZE2*NSIZE2 + 16*NSIZE2*NSIZE1*NSIZE2
      NLOOPS = NLOOPS+1
 
C ------------------------------------------------------------------------------
      TSTART = RTC()
      DO 5500 IT = 1,NSIZE2
        TQI = B1(IT)
        UQI = F1(IT)
        DO 5450 IS = 1,NSIZE1
          A2(IS,IT) = UQI*TQI*A1(IS)
 5450   CONTINUE
 5500 CONTINUE
      TLOOPS(NLOOPS) = RTC()-TSTART
      FLOOPS(NLOOPS) = 2*NSIZE1*NSIZE2
      NLOOPS = NLOOPS+1
 
C ------------------------------------------------------------------------------
      TSTART = RTC()
      DO 5600 MP = 1,NSIZE2
        DO 5570 MQ = 1,NSIZE2
          VAL = T2(MQ)
          DO 5530 MI = 1,NSIZE1
            Q2(MI,MQ) = Q2(MI,MQ) + VAL*V(MI,MP)
            Q2(MI,MP) = Q2(MI,MP) + VAL*V(MI,MQ)
 5530     CONTINUE
 5570   CONTINUE
 5600 CONTINUE
      TLOOPS(NLOOPS) = RTC()-TSTART
      FLOOPS(NLOOPS) = 4*NSIZE1*NSIZE2*NSIZE2
      NLOOPS = NLOOPS+1
 
C ------------------------------------------------------------------------------
      TSTART = RTC()
      DO 5700   K = 1,NSIZE1
        A1(K) = (A1(K)+F1(K)) + A2(K,2)*A2(K,5)*B1(K)
 5700 CONTINUE
      TLOOPS(NLOOPS) = RTC()-TSTART
      FLOOPS(NLOOPS) = 3*NSIZE1
      NLOOPS = NLOOPS+1
 
C ------------------------------------------------------------------------------
      TSTART = RTC()
      DO 5800   J = 1,NSIZE2
        DO 5770   K = 1,NSIZE3
          DO 5730   I = 1,NSIZE1
            E3(I,J,K) = E3(I,J,K) + A1(J)*D3(I,J,K)
            E3(I,J,K) = E3(I,J,K) + A1(J)*C3(I,J,K)
            CC = D3(I,J,K)
            CCC = C3(I,J,K)
            D3(I,J,K) = B3(I,J,K)
            C3(I,J,K) = A3(I,J,K)
            B3(I,J,K) = CC
            A3(I,J,K) = CCC
 5730     CONTINUE
 5770   CONTINUE
 5800 CONTINUE
      TLOOPS(NLOOPS) = RTC()-TSTART
      FLOOPS(NLOOPS) = 4*NSIZE1*NSIZE2*NSIZE3
      NLOOPS = NLOOPS+1
 
C ------------------------------------------------------------------------------
      TSTART = RTC()
      DO 5900   I = 1,NSIZE2
        DO 5870   J = 1,NSIZE2
          S = 0.
          DO 5830   K = 1,NSIZE1
            S = S + AM(K)*(DR(1,I,K)*DR(1,J,K)+DR(2,I,K)*DR(2,J,K)+
     1         DR(3,I,K)*DR(3,J,K))
 5830     CONTINUE
          GTEN(I,J) = S
          GTEN(J,I) = S
 5870   CONTINUE
 5900 CONTINUE
      TLOOPS(NLOOPS) = RTC()-TSTART
      FLOOPS(NLOOPS) = 7*NSIZE1*NSIZE2*NSIZE2
      NLOOPS = NLOOPS+1
 
 
C ------------------------------------------------------------------------------
      TSTART = RTC()
      DO 6000   I = 1,NSIZE2
        SUM = 0.
        DO 5950 L = 1,NSIZE1
          SUM = SUM + A2(L,I)*B1(L)
 5950   CONTINUE
        B1(I) = B1(I) - SUM
 6000 CONTINUE
      TLOOPS(NLOOPS) = RTC()-TSTART
      FLOOPS(NLOOPS) = 2*NSIZE1*NSIZE2 + NSIZE2
      NLOOPS = NLOOPS+1

      LMN = 2
      LMX = NSIZE2-1
      KMN = 2
      KMX = NSIZE1-1
      DTN = 4.56
      DO 6020   I = 1,NSIZE2
        DO 6010   J = 1,NSIZE1
          E2(J,I) = 1.
          F2(J,I) = 1.
 6010   CONTINUE
 6020 CONTINUE
C ------------------------------------------------------------------------------
      TSTART = RTC()
      DO 6100 L = 2, LMX
        DO 6060   K = 2, KMX
          A1(K) = (A2(K,L)+B2(K,L))*(C2(K,L-1)-C2(K-1,L)) + (A2(K+1,L) +
     1       B2(K+1,L))*(C2(K+1,L)-C2(K,L-1)) + (A2(K,L+1)+B2(K,L+1))*
     2       (C2(K-1,L)-C2(K,L+1)) + (A2(K+1,L+1)+B2(K+1,L+1))*
     3       (C2(K,L+1)-C2(K+1,L))
          B1(K) = (A2(K,L)+B2(K,L))*(D2(K,L-1)-D2(K-1,L)) + (A2(K+1,L) +
     1       B2(K+1,L))*(D2(K+1,L)-D2(K,L-1)) + (A2(K,L+1)+B2(K,L+1))*
     2       (D2(K-1,L)-D2(K,L+1)) + (A2(K+1,L+1)+B2(K+1,L+1))*
     3       (D2(K,L+1)-D2(K+1,L))
          F1(K) = E2(K,L)*F2(K,L) + E2(K+1,L)*F2(K+1,L) + E2(K,L+1)*
     1       F2(K,L+1) + E2(K+1,L+1)*F2(K+1,L+1)
          F1(K) = 2./F1(K)
          A1(K) = -A1(K)*F1(K)
          B1(K) = B1(K)*F1(K)
          G2(K,L) = G2(K,L) + DTN*A1(K)
          WR2(K,L) = WR2(K,L) + DTN*B1(K)
 6060   CONTINUE
 6100 CONTINUE
      TLOOPS(NLOOPS) = RTC()-TSTART
      FLOOPS(NLOOPS) = 44*(NSIZE2-1)*(NSIZE1-1)
      NLOOPS = NLOOPS+1
 
      LMNP = 2
      LMX = NSIZE2-1
      KMNP = 1
      KMX = NSIZE1
      DO 6120   I = 1,NSIZE1
        DO 6110 L = 1,NSIZE2
          C2(I,L) = 2.5
 6110   CONTINUE
 6120 CONTINUE
C ------------------------------------------------------------------------------
      TSTART = RTC()
      DO 6200 L = 2, LMX
        DO 6160   K = 1,KMX
          A1(K) = C2(K,L) + D2(K,L) + D2(K,L-1)*(1.-A2(K,L-1))
          A2(K,L) = D2(K,L)/A1(K)
          B2(K,L) = (C2(K,L)*E2(K,L)+D2(K,L-1)*B2(K,L-1))/A1(K)
 6160   CONTINUE
 6200 CONTINUE
      TLOOPS(NLOOPS) = RTC()-TSTART
      FLOOPS(NLOOPS) = 9*(NSIZE2-1)*NSIZE1
      NLOOPS = NLOOPS+1
 
      LCURR = 1
      DVOL = 3.52
      DTDP = 7.825
C ------------------------------------------------------------------------------
      TSTART = RTC()
      DO 6300   I = 1,NSIZE2
        UQ(I) = 0.
        DUQ(I) = 0.
        TQ(I) = 0.
        DTQ(I) = 0.
        DO 6230   JK = 1,NSIZE1
          A2(JK,I) = C2(JK,I)*FTP(I) + D2(JK,I)*FPP(I)
          B2(JK,I) = D2(JK,I)*FTP(I) + E2(JK,I)*FPP(I)
          IF (LCURR .EQ. 1) THEN
             UQ(I) = UQ(I) - DTDP*A2(JK,I)
             DUQ(I) = DUQ(I) + DTDP*B2(JK,I)
          ENDIF
          IF (LCURR .EQ. 2) THEN
             UQ(I) = UQ(I) + DTDP*A2(JK,I)
             DUQ(I) = DUQ(I) - DTDP*B2(JK,I)
          ENDIF
          FPP(I) = FPP(I)
          TQ(I) = TQ(I) - DTDP*F2(JK,I)
 6230   CONTINUE
        DO 6270   JK = 1,NSIZE1
          DTQ(I) = DTQ(I) + 0.5*G2(JK,I)*F2(JK,I)*DVOL
 6270   CONTINUE
 6300 CONTINUE
      TLOOPS(NLOOPS) = RTC()-TSTART
      FLOOPS(NLOOPS) = 16*NSIZE1*NSIZE2
      NLOOPS = NLOOPS+1
 
 
      NN = NSIZE2
      KE = 1
      LS = 1
      LE = NSIZE1
C ------------------------------------------------------------------------------
      TSTART = RTC()
      DO 6400   I = 1,NN
        DO 6350 L = 1,LE
          Q6(L,I) = F(L,1,I) - E(L,I,1)*F(L,5,1) - E(L,I,2)*F(L,5,2) -
     1        E(L,I,3)*F(L,5,3) - E(L,I,4)*F(L,5,4) - E(L,I,5)*F(L,5,5)
 6350   CONTINUE
 6400 CONTINUE
      TLOOPS(NLOOPS) = RTC()-TSTART
      FLOOPS(NLOOPS) = 10*NSIZE1*NSIZE2
      NLOOPS = NLOOPS+1
 
      EPS = 3.111
C ------------------------------------------------------------------------------
      TSTART = RTC()
      DO 6500   I = 1,NSIZE2
        DO 6430   J = 1,NSIZE3
          DO 6410 L = 1,NSIZE1
            D3(L,I,J) = D3(L,I,J) - D3(L,I,J)*D3(L,I,J)
 6410     CONTINUE
          DO 6420 L = 1,NSIZE1
            D3(L,I,J) = D3(L,I,J)*D3(L,1,J)
 6420     CONTINUE
 6430   CONTINUE

        DO 6440 L = 1,NSIZE1
          A1(L) = EPS*D3(L,1,J)
 6440   CONTINUE
        DO 6460   J = 1,NSIZE3
          DO 6450 L = 1,NSIZE1
            D3(L,I,J) = D3(L,I,J) - D3(L,I,J)**2
 6450     CONTINUE
 6460   CONTINUE
        DO 6480 L = 1,NSIZE1
          D3(L,1,J) = ABS(A1(L)+D3(L,1,J))
 6480   CONTINUE
 6500 CONTINUE
      TLOOPS(NLOOPS) = RTC()-TSTART
      NALL = NSIZE1*NSIZE2*NSIZE3
      FLOOPS(NLOOPS) = 5*NALL + 2*NSIZE1*NSIZE2
      NLOOPS = NLOOPS+1
 
 
      DO 6520 I = 1,NSIZE1
      DO 6520 J = 1,NSIZE2
 6520   AR(I,J) = 1.0
C ------------------------------------------------------------------------------
      TSTART = RTC()
      DO 6600   J = 1,NSIZE2
        A1(J) = 0.0
        DO 6530   I = 1,NSIZE1
          A2(I,J) = C2(I,J)*(D2(I,J)*(B2(I,J)-B1(I))+E2(I,J)*(B2(I,J)-
     1       F1(I))+F2(I,J)*(B2(I,J)-D1(I))+G2(I,J)*(B2(I,J)-C(I))-
     2       AR(I,J))
 6530   CONTINUE
        DO 6570   I = 1,NSIZE1
          A1(J) = A1(J) + A2(I,J)*A2(I,J)
 6570   CONTINUE
 6600 CONTINUE
      TLOOPS(NLOOPS) = RTC()-TSTART
      FLOOPS(NLOOPS) = 15*NSIZE1*NSIZE2
      NLOOPS = NLOOPS+1
 
C ------------------------------------------------------------------------------
      TSTART = RTC()
      DO 6700 J4 = 1,16
        DO 6650 J3 = 1,NSIZE1
          A1(J3) = A1(J3) + E11((J3-1)*16+J4)*P11((J3-1)*16+J4)
          B1(J3) = B1(J3) + F11((J3-1)*16+J4)*P11((J3-1)*16+J4)
          F1(J3) = F1(J3) + D11((J3-1)*16+J4)*P11((J3-1)*16+J4)
          D1(J3) = D1(J3) + G11((J3-1)*16+J4)*P11((J3-1)*16+J4)
          DSQ(J3) = DSQ(J3) + H11((J3-1)*16+J4)*P11((J3-1)*16+J4)
 6650   CONTINUE
 6700 CONTINUE
      TLOOPS(NLOOPS) = RTC()-TSTART
      FLOOPS(NLOOPS) = 10*16*NSIZE1
      NLOOPS = NLOOPS+1
 
      IRAD = NSIZE3
      NOX = NSIZE1
      NOY = NSIZE2
      NOZ = NSIZE3
      IF (NSIZE1 .EQ. NSIZE3) IRAD = 1
      INNER = NSIZE1 - 2*IRAD
C ------------------------------------------------------------------------------
      TSTART = RTC()
      DO 6800   IY = 1,NOY
        DO 6780   IZ = 1,NOZ
          DO 6720   IX = 1 + IRAD, NOX - IRAD
            A11((IZ-1)*NOY*NOX+(IY-1)*NOX+IX) = B11((IZ-1)*NOY*NOX+
     1         (IY-1)*NOX+IX)*A1(1)
 6720     CONTINUE

          DO 6760   K = 1,IRAD
            DO 6740   IX = 1 + IRAD, NOX - IRAD
              A11((IZ-1)*NOY*NOX+(IY-1)*NOX+IX) = A11((IZ-1)*NOY*NOX+
     1           (IY-1)*NOX+IX)+(B11((IZ-1)*NOY*NOX+(IY-1)*NOX+IX+K)+
     2           B11((IZ-1)*NOY*NOX+(IY-1)*NOX+IX-K))*A1(K+1)
 6740       CONTINUE
 6760     CONTINUE
 6780   CONTINUE
 6800 CONTINUE
      TLOOPS(NLOOPS) = RTC()-TSTART
      FLOOPS(NLOOPS) = IRAD*NSIZE2*(INNER+2*IRAD*INNER)
      NLOOPS = NLOOPS+1
 
      DO 6830   K = 1,NSIZE3
        DO 6820   J = 1,NSIZE2
          DO 6810   I = 1,NSIZE1
            D3(I,J,K) = 1.0
            B3(I,J,K) = 1.0
 6810     CONTINUE
 6820   CONTINUE
 6830 CONTINUE
      NRHS = NSIZE1
      NMAT = NSIZE2
      NNN = NSIZE3
C ------------------------------------------------------------------------------
      TSTART = RTC()
      DO 6900   L = 1,NMAT
        DO 6860   K = 1,NNN
          DO 6840 I = 1,NRHS
            D3(I,L,K) = D3(I,L,K)*B3(I,1,K)
 6840     CONTINUE
          DO 6850 I = 1,NRHS
            D3(I,L,K) = D3(I,L,K) - B3(I,1,K)*D3(I,L,K)
 6850     CONTINUE
 6860   CONTINUE
 
        DO 6890   K = NNN,1,-1
          DO 6870 I = 1,NRHS
            D3(I,L,K) = D3(I,L,K)*B3(I,1,K)
 6870     CONTINUE
          DO 6880 I = 1,NRHS
            D3(I,L,K) = D3(I,L,K) - B3(I,1,K)*D3(I,L,K)
 6880     CONTINUE
 6890   CONTINUE
 6900 CONTINUE
      TLOOPS(NLOOPS) = RTC()-TSTART
      FLOOPS(NLOOPS) = 6*NSIZE1*NSIZE2*NSIZE3
      NLOOPS = NLOOPS+1
 
      TPI = PI
      DO 6910   I = 1,NSIZE3
        A2(1,I) = .2
        A2(2,I) = .2
        A2(3,I) = .2
 6910 CONTINUE
      DO 6920   I = 1,NSIZE1
        P2(1,I) = 1.
        P2(2,I) = 1.
        P2(3,I) = 1.
 6920 CONTINUE
      OMEGA = PI
C ------------------------------------------------------------------------------
      TSTART = RTC()
      DO 7000 NT = 1,NSIZE2
        DO 6970 IG = 1,NSIZE3
          CMPLX2(IG,NT) = (0.0,0.0)
          DO 6940 IN = 1,NSIZE1
            ARG = (A2(1,IG)*P2(1,IN)+A2(2,IG)*P2(2,IN)+A2(3,IG)*
     1          P2(3,IN))*TPI
            CMPLX2(IG,NT)=CMPLX2(IG,NT)+CMPLX(COS(ARG),(-SIN(ARG)))

 6940     CONTINUE
          CMPLX2(IG,NT) = CMPLX2(IG,NT)/OMEGA
 6970   CONTINUE
 7000 CONTINUE
      TLOOPS(NLOOPS) = RTC()-TSTART
      FLOOPS(NLOOPS) = 7*NSIZE1*NSIZE2*NSIZE3 + NSIZE3*NSIZE2
      NLOOPS = NLOOPS+1
 
      L = 0
C ------------------------------------------------------------------------------
      TSTART = RTC()
      DO 7100   I = 1,NSIZE1
        DO 7070   J = 1,NSIZE2
          S = 0.
          DO 7030   K = 1,NSIZE2
            S = S + A2(I,K)*A1(K)*B2(J,K)
 7030     CONTINUE
          B11(J) = S
          C2(I,J) = S
 7070   CONTINUE
 7100 CONTINUE
      TLOOPS(NLOOPS) = RTC()-TSTART
      FLOOPS(NLOOPS) = 3*NSIZE1*NSIZE2*NSIZE2
      NLOOPS = NLOOPS+1
 
      MT = NSIZE2-1
      MX = NSIZE3/2
C ------------------------------------------------------------------------------
      TSTART = RTC()
      DO 7200   J = 1,MT + 1
        DO 7170   K = 1,2*MX
 
          J1 = J - 1
          K1 = K - 1
          IF (K1 .GT. MX) K1 = K1 - 2*MX
          DO 7130   I = 1,NSIZE1
            CMP2 = EXP((0.,1.)*(J1*PI/(2*MT)+K1*PI/(2*MX)))
            CMP1(I) = D3(I,J,K) + (0.,1.)*B3(I,J,K)
            CMP1(I) = CMP2*CMP1(I)
            D3(I,J,K) = CMP1(I)
            B3(I,J,K) = (0.,-1.)*CMP1(I)
            CMP1(I) = D3(I,J,K) + (0.,1.)*B3(I,J,K)
            CMP1(I) = CMP2*CMP1(I)
            D3(I,J,K) = CMP1(I)
            B3(I,J,K) = (0.,-1.)*CMP1(I)
 
            CMP1(I) = D3(I,J,K) + (0.,1.)*B3(I,J,K)
            CMP1(I) = CMP2*CMP1(I)
            D3(I,J,K) = CMP1(I)
            B3(I,J,K) = (0.,-1.)*CMP1(I)
 7130     CONTINUE
 7170   CONTINUE
 7200 CONTINUE
      TLOOPS(NLOOPS) = RTC()-TSTART
      FLOOPS(NLOOPS) = 31*NSIZE1*NSIZE2*NSIZE3
      NLOOPS = NLOOPS+1
 
      DO 7220   I = 1,NSIZE2
        DO 7210   J = 1,NSIZE1
          C2(J,I) = 0.1
 7210   CONTINUE
 7220 CONTINUE
C ------------------------------------------------------------------------------
      TSTART = RTC()
      DO 7300   I = 1,NSIZE2
        DO 7250   J = 1,NSIZE1
          A2(J,I) = ABS(C2(J,I))
          B2(J,I) = SIN(C2(J,I))
          B2(J,I) = COS(C2(J,I))
          B2(J,I) = SQRT(C2(J,I))
          B2(J,I) = EXP(C2(J,I))
          B2(J,I) = LOG(C2(J,I))
 7250   CONTINUE
 7300 CONTINUE
      TLOOPS(NLOOPS) = RTC()-TSTART
C  "45" FROM HARDWARE PERFORMANCE MONITOR FOR THIS SPECIFIC DATA CASE
      FLOOPS(NLOOPS) = 45*NSIZE1*NSIZE2

      LOOPS=1000
      GM = 1.
      DO 9900 I = 1,NLOOPS
        TIME = (TLOOPS(I)*CLOCK)
        TWT = TWT + TIME
        TFLOPS = TFLOPS + FLOOPS(I)
        MFLOPS = (FLOOPS(I)/TIME)*1.E-6
        GM = GM * MFLOPS
        PRINT 12,   I,LOOPS,TIME,MFLOPS
        LOOPS = LOOPS +100
 9900 CONTINUE

      MFLOPS = (TFLOPS/TWT)*1.E-06
      GM = GM**(1./64.)
      PRINT 14,   NCASE, TWT, MFLOPS
      PRINT 16,   GM
 
        RETURN
   10 FORMAT(/'  Case',I3,':    NSIZE1 =',I5,',    NSIZE2 =',I4,
     1 ',    NSIZE3 =',I3/)
   12 FORMAT(I5,')   "DO',I5,'" Loop     Wallclock',F12.7,
     1 's, ',F9.1,' MFlops')
   14 FORMAT(/'  Case',I3,' Aggregates:     Wallclock',F9.2,'s,   ',
     1 F9.1,' MFlops')
   16 FORMAT(/'  Geometric Mean:',2x,f9.2,///)
      END


