PROGRAM main

USE SOA

IMPLICIT NONE


  TYPE(myStructure) :: sa
  INTEGER :: i

  CALL sa % Build(100)

  !$omp target map(sa % array)
  !$omp teams distribute parallel do
  DO i = 1, 100
    sa % array(i) = 1.0
  ENDDO
  !$omp end target

  CALL sa % Free()

END PROGRAM main

