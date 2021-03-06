! ******************************************************************************************************************************** !
! atchem_lib.f90
! Atmosphere Chemistry
! LIBRARY MODULE
! ******************************************************************************************************************************** !

MODULE atchem_lib

  use gem_util
  use gem_carbchem
  IMPLICIT NONE
  SAVE

  ! ****************************************************************************************************************************** !
  ! *** NAMELIST DEFINITIONS ***************************************************************************************************** !
  ! ****************************************************************************************************************************** !

  ! ### EDIT ADD AND/OR EXTEND NAME-LIST PARAMETER AND CONTROL OPTIONS ########################################################### !
  ! ------------------- TRACER INITIALIZATION ------------------------------------------------------------------------------------ !
  REAL,DIMENSION(n_atm)::atm_init                              ! atmosphere tracer array initial values
  NAMELIST /ini_atchem_nml/atm_init
  ! ------------------- COSMOGENIC & RADIOGENIC PRODUCTION  ---------------------------------------------------------------------- !
  real::par_atm_F14C                                           ! Global cosmogenic production rate of 14C (mol yr-1)
  NAMELIST /ini_atchem_nml/par_atm_F14C
  ! ------------------- EMISSIONS-TO-ATMOSPHERE ---------------------------------------------------------------------------------- !
  real::par_atm_wetlands_FCH4                                  ! Wetlands CH4 flux (mol yr-1)
  real::par_atm_wetlands_FCH4_d13C                             ! Wetlands CH4 d13C (o/oo)
  NAMELIST /ini_atchem_nml/par_atm_wetlands_FCH4,par_atm_wetlands_FCH4_d13C
  ! ------------------- SLAB BIOSPHERE ------------------------------------------------------------------------------------------- !
  real::par_atm_slabbiosphere_C                                  !
  real::par_atm_slabbiosphere_C_d13C                             !
  NAMELIST /ini_atchem_nml/par_atm_slabbiosphere_C,par_atm_slabbiosphere_C_d13C
  real::par_atm_FterrCO2exchange          !
  NAMELIST /ini_atchem_nml/par_atm_FterrCO2exchange
  ! ------------------- RUN CONTROL ---------------------------------------------------------------------------------------------- !
  logical::ctrl_continuing                                     ! continuing run?
  NAMELIST /ini_atchem_nml/ctrl_continuing
  ! ------------------- I/O DIRECTORY DEFINITIONS -------------------------------------------------------------------------------- !
  CHARACTER(len=255)::par_indir_name                           !
  CHARACTER(len=255)::par_outdir_name                          !
  CHARACTER(len=255)::par_rstdir_name                          !
  NAMELIST /ini_atchem_nml/par_indir_name,par_outdir_name,par_rstdir_name
  CHARACTER(len=127)::par_infile_name,par_outfile_name         !
  NAMELIST /ini_atchem_nml/par_infile_name,par_outfile_name
  ! ------------------- DATA SAVING: MISC ---------------------------------------------------------------------------------------- !
  LOGICAL::ctrl_ncrst                                          ! restart as netCDF format?
  NAMELIST /ini_atchem_nml/ctrl_ncrst
  CHARACTER(len=127)::par_ncrst_name                           !
  NAMELIST /ini_atchem_nml/par_ncrst_name
  ! ############################################################################################################################## !


  ! ****************************************************************************************************************************** !
  ! *** MODEL CONFIGURATION CONSTANTS ******************************************************************************************** !
  ! ****************************************************************************************************************************** !

  ! *** array dimensions ***
  ! grid dimensions
  INTEGER :: n_i, n_j
  ! grid properties array dimensions
  INTEGER :: n_phys_atm

  ! *** array index values ***
  ! atmosperhic 'physics' properties array indices
  INTEGER,PARAMETER::ipa_lat                              = 01    ! latitude (degrees) [mid-point]
  INTEGER,PARAMETER::ipa_lon                              = 02    ! longitude (degrees) [mid-point]
  INTEGER,PARAMETER::ipa_dlat                             = 03    ! latitude (degrees) [width]
  INTEGER,PARAMETER::ipa_dlon                             = 04    ! longitude (degrees) [width]
  INTEGER,PARAMETER::ipa_latn                             = 05   ! latitude (degrees) [north edge]
  INTEGER,PARAMETER::ipa_lone                             = 06   ! longitude (degrees) [east edge]
  INTEGER,PARAMETER::ipa_hmid                             = 07    ! height (m) [mid-point]
  INTEGER,PARAMETER::ipa_dh                               = 08    ! height (m) [thickness]
  INTEGER,PARAMETER::ipa_hbot                             = 09    ! height (m) [bottom]
  INTEGER,PARAMETER::ipa_htop                             = 10    ! height (m) [top]
  INTEGER,PARAMETER::ipa_A                                = 11    ! area (m2)
  INTEGER,PARAMETER::ipa_rA                               = 12    ! reciprocal area (to speed up numerics)
  INTEGER,PARAMETER::ipa_V                                = 13    ! atmospheric box volume (m3)
  INTEGER,PARAMETER::ipa_rV                               = 14    ! reciprocal volume (to speed up numerics)
  INTEGER,PARAMETER::ipa_P                                = 15    ! pressure (atm)

  ! *** array index names ***

  ! *** miscellaneous ***
  ! effective thickness of atmosphere (m) in the case of a 1-cell thick atmosphere
  ! NOTE: was 8000.0 m in Ridgwell et al. [2007]
  REAL,parameter::par_atm_th = 7777.0

  ! *********************************************************
  ! *** GLOBAL VARIABLE AND RUN-TIME SET PARAMETER ARRAYS ***
  ! *********************************************************

  ! *** PRIMARY ATCHEM ARRAYS ***
  REAL, DIMENSION(:,:,:), ALLOCATABLE :: atm, fatm, phys_atm

  ! *** Miscellanenous ***
  !
  REAL, DIMENSION(:,:,:), ALLOCATABLE  :: atm_slabbiosphere
  ! netCDF and netCDF restart parameters
  CHARACTER(len=31)::string_rstid                              !
  CHARACTER(len=7) ::string_ncrunid                            !
  CHARACTER(len=254) ::string_ncrst                            !
  integer::ncrst_ntrec                                         ! count for netcdf datasets
  integer::ncrst_iou                                           ! io for netcdf restart

END MODULE atchem_lib
