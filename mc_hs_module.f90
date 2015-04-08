! mc_hs_module.f90 (used by mc_nvt_hs.f90)
! Monte Carlo simulation, hard spheres
MODULE mc_hs_module

  IMPLICIT NONE
  PRIVATE
  PUBLIC :: n, r, lt, ne, gt
  PUBLIC :: overlap_1, overlap, n_overlap_1, n_overlap

  INTEGER                             :: n ! number of atoms
  REAL,   DIMENSION(:,:), ALLOCATABLE :: r ! positions (3,:)

  INTEGER, PARAMETER :: lt = -1, ne = 0, gt = 1 ! j-range options

CONTAINS

  FUNCTION overlap ( sigma )
    LOGICAL             :: overlap ! shows if an overlap was detected
    REAL,    INTENT(in) :: sigma   ! hard sphere diameter

    INTEGER :: i

    IF ( n > SIZE(r,dim=2) ) STOP 'Array bounds error for r in energy'

    overlap  = .FALSE.

    DO i = 1, n - 1
       IF ( overlap_1 ( r(:,i), i, gt, sigma ) ) THEN
          overlap = .TRUE.
          EXIT ! jump out of loop
       END IF
    END DO

  END FUNCTION overlap

  FUNCTION overlap_1 ( ri, i, j_range, sigma ) RESULT ( overlap )
    LOGICAL                        :: overlap    ! shows if an overlap was detected
    REAL, DIMENSION(3), INTENT(in) :: ri         ! coordinates of atom of interest
    INTEGER,            INTENT(in) :: i, j_range ! index, and partner index range
    REAL,               INTENT(in) :: sigma      ! hard sphere diameter

    ! Detects overlap of atom in ri
    ! with j/=i, j>i, or j<i depending on j_range
    ! It is assumed that r, sigma are in units where box = 1

    INTEGER            :: j, j1, j2
    REAL               :: sigma_sq
    REAL, DIMENSION(3) :: rij

    IF ( n > SIZE(r,dim=2) ) STOP 'Array bounds error for r in energy'

    sigma_sq = sigma**2

    overlap = .FALSE.

    SELECT CASE ( j_range )
    CASE ( lt ) ! j < i
       j1 = 1
       j2 = i-1
    CASE ( gt ) ! j > i
       j1 = i+1
       j2 = n
    CASE ( ne ) ! j /= i
       j1 = 1
       j2 = n
    END SELECT

    DO j = j1, j2

       IF ( i == j ) CYCLE

       rij(:) = ri(:) - r(:,j)
       rij(:) = rij(:) - ANINT ( rij(:) ) ! periodic boundaries in box=1 units

       IF ( SUM ( rij**2 ) < sigma_sq ) THEN
          overlap = .TRUE.
          EXIT ! jump out of loop
       END IF

    END DO

  END FUNCTION overlap_1

  FUNCTION n_overlap ( sigma )
    INTEGER             :: n_overlap ! counts overlaps
    REAL,    INTENT(in) :: sigma     ! hard sphere diameter

    INTEGER :: i

    IF ( n > SIZE(r,dim=2) ) STOP 'Array bounds error for r in energy'

    n_overlap  = 0

    DO i = 1, n - 1
       n_overlap = n_overlap + n_overlap_1 ( r(:,i), i, gt, sigma )
    END DO

  END FUNCTION n_overlap

  FUNCTION n_overlap_1 ( ri, i, j_range, sigma ) RESULT ( n_overlap )
    INTEGER                        :: n_overlap  ! counts overlaps
    REAL, DIMENSION(3), INTENT(in) :: ri         ! coordinates of atom of interest
    INTEGER,            INTENT(in) :: i, j_range ! index, and partner index range
    REAL,               INTENT(in) :: sigma      ! hard sphere diameter

    ! Counts overlaps of atom in ri
    ! with j/=i, j>i, or j<i depending on j_range
    ! It is assumed that r, sigma are in units where box = 1

    INTEGER            :: j, j1, j2
    REAL               :: sigma_sq
    REAL, DIMENSION(3) :: rij

    IF ( n > SIZE(r,dim=2) ) STOP 'Array bounds error for r in energy'

    sigma_sq = sigma**2

    n_overlap = 0

    SELECT CASE ( j_range )
    CASE ( lt ) ! j < i
       j1 = 1
       j2 = i-1
    CASE ( gt ) ! j > i
       j1 = i+1
       j2 = n
    CASE ( ne ) ! j /= i
       j1 = 1
       j2 = n
    END SELECT

    DO j = j1, j2

       IF ( i == j ) CYCLE

       rij(:) = ri(:) - r(:,j)
       rij(:) = rij(:) - ANINT ( rij(:) ) ! periodic boundaries in box=1 units

       IF ( SUM ( rij**2 ) < sigma_sq ) n_overlap = n_overlap + 1

    END DO

  END FUNCTION n_overlap_1

END MODULE mc_hs_module