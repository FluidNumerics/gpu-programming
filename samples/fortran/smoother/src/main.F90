PROGRAM main

USE smoother

IMPLICIT NONE

  INTEGER, PARAMETER :: nW = 2
  INTEGER :: nX, nY, nIter
  REAL(prec), ALLOCATABLE :: f(:,:)
  REAL(prec), ALLOCATABLE :: smoothF(:,:)
  REAL(prec), ALLOCATABLE :: weights(:,:)
  REAL(prec) :: dx, dy, x, y
  INTEGER :: i, j, iter 


    CALL GetCLIConf( nX, nY, nIter )
    
    ALLOCATE( f(1:nX,1:nY), smoothF(1:nX,1:nY), weights(-nW:nW,-nW:nW) )

    ! Create gaussian weights
    DO j = -nW, nW
      y = REAL(j,prec)
      DO i = -nW, nW
        x = REAL(i,prec)
        weights(i,j) = exp( -(x**2 + y**2)/(0.5_prec) )
      ENDDO
    ENDDO

    dx = 2.0_prec/REAL(nX, prec)
    dy = 2.0_prec/REAL(nY, prec)

    ! Initialize f and smoothF
    DO j = 1, nY
      y = -1.0_prec + dy*REAL(j-1,prec)
      DO i = 1, nX
        x = -1.0_prec + dx*REAL(i-1,prec)
        f(i,j) = tanh(x/0.001_prec)*tanh(y/0.001_prec)
        smoothF(i,j) = f(i,j)
      ENDDO
    ENDDO

    ! Write the initial condition to file
    OPEN(UNIT=2, FILE='function.txt', STATUS='REPLACE', ACTION='WRITE')
    DO j = 1, nY
      DO i = 1, nX
        WRITE(2,'(E12.4)') f(i,j)
      ENDDO
    ENDDO
    CLOSE(UNIT=2)

    DO iter = 1, nIter

      CALL ApplySmoother( f, weights, smoothF, nW, nX, nY )
      CALL ResetF( f, smoothF, nW, nX, nY )

    ENDDO

    ! Write the initial condition to file
    OPEN(UNIT=2, FILE='smooth-function.txt', STATUS='REPLACE', ACTION='WRITE')
    DO j = 1, nY
      DO i = 1, nX
        WRITE(2,'(E12.4)') smoothF(i,j)
      ENDDO
    ENDDO
    CLOSE(UNIT=2)


    DEALLOCATE( f, smoothF, weights )


END PROGRAM main

