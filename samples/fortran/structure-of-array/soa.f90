MODULE SOA


IMPLICIT NONE

  TYPE myStructure
    INTEGER :: n
    REAL, POINTER :: array(:)
    CONTAINS

      PROCEDURE :: Build
      PROCEDURE :: Free
  END TYPE myStructure

CONTAINS

SUBROUTINE Build(this,n)
  IMPLICIT NONE
  CLASS(myStructure),INTENT(out) :: this
  INTEGER, INTENT(in) :: n

  this % n = n
  ALLOCATE(this % array(1:n))
  this % array = 0.0
  !$omp target enter data map(to:this % array)

END SUBROUTINE Build

SUBROUTINE Free(this)
  IMPLICIT NONE
  CLASS(myStructure),INTENT(inout) :: this

  this % n = -1
  DEALLOCATE(this % array)

END SUBROUTINE Free



END MODULE SOA

