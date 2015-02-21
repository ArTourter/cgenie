SUBROUTINE initialise_genie()
  USE genie_control
  USE genie_global
  USE genie_util, ONLY: check_unit, check_iostat, message, die
  IMPLICIT NONE

  INTEGER :: ios, unitNum=8
  ! DEFUNCT
  LOGICAL :: flag_glim_t2m_force, flag_glim_pforce

  ! Top-level control namelist
  NAMELIST /genie_control_nml/ &
       & koverall_total, katm_loop, ksic_loop, kocn_loop, klnd_loop, &
       & conv_kocn_katchem, conv_kocn_kbiogem, conv_kocn_ksedgem, &
       & conv_kocn_krokgem, kgemlite, flag_ebatmos, flag_igcmatmos, &
       & flag_fixedocean, flag_slabocean, flag_goldsteinocean, &
       & flag_fixedseaice, flag_slabseaice, flag_goldsteinseaice, &
       & flag_icesheet, flag_fixedatmos, flag_fakeatmos, flag_land, &
       & flag_ents, flag_fixedland, flag_fixedicesheet, flag_fixedchem, &
       & flag_biogem, flag_atchem, flag_sedgem, flag_rokgem, flag_ichem, &
       & flag_wind, flag_gemlite, write_flag_atm, write_flag_ocn, &
       & write_flag_sic, outputdir_name, dt_write, fname_restart_main, &
       & fname_fluxrestart, flag_checkfluxes_sic, flag_checkfluxes_ocn, &
       & flag_checkfluxes_surf, flag_checkfluxes_atlantic, genie_timestep, &
       & lrestart_genie, flag_glim_t2m_force, flag_glim_pforce, &
       & genie_solar_constant, fname_topo, verbosity, &
       & debug_init, debug_end, debug_loop, gem_yr, gem_yr_min, &
       & gem_yr_max, gem_notyr, gem_notyr_min, gem_notyr_max, gem_dyr, &
       & gem_adapt_auto, gem_adapt_dpCO2dt, gem_adapt_DpCO2, &
       & gem_adapt_auto_unlimitedGEM, gem_adapt_diag_biogem_full

  ! Assign default values
  koverall_total = 0
  conv_kocn_katchem = -1
  conv_kocn_ksedgem = -1
  conv_kocn_kbiogem = -1
  conv_kocn_krokgem = -1
  kgemlite = 1
  flag_igcmatmos = .FALSE.
  flag_ebatmos = .FALSE.
  flag_fixedatmos = .FALSE.
  flag_fakeatmos = .FALSE.
  flag_fixedocean = .FALSE.
  flag_slabocean = .FALSE.
  flag_goldsteinocean = .TRUE.
  flag_fixedseaice = .FALSE.
  flag_slabseaice = .FALSE.
  flag_goldsteinseaice = .TRUE.
  flag_icesheet = .FALSE.
  flag_fixedicesheet = .TRUE.
  flag_land = .FALSE.
  flag_ents = .FALSE.
  flag_fixedland = .FALSE.
  flag_fixedchem = .FALSE.
  flag_biogem = .FALSE.
  flag_atchem = .FALSE.
  flag_sedgem = .FALSE.
  flag_rokgem = .FALSE.
  flag_gemlite = .FALSE.
  write_flag_atm = .TRUE.
  write_flag_ocn = .TRUE.
  write_flag_sic = .TRUE.
  outputdir_name = '~/genie_output/main'
  fname_restart_main = 'xxx'
  fname_fluxrestart = 'xxx'
  dt_write = 1
  flag_checkfluxes_sic = .FALSE.
  flag_checkfluxes_ocn = .FALSE.
  flag_checkfluxes_surf = .FALSE.
  flag_checkfluxes_atlantic = .FALSE.
  genie_timestep = 3600.0
  genie_clock = 0
  lrestart_genie = .FALSE.
  genie_solar_constant = 1368.0
  verbosity = 0
  debug_init = 1
  fname_topo = 'worbe2'

  CALL check_unit(unitNum, __LINE__, __FILE__)
  OPEN(UNIT=unitNum,FILE='data_genie',STATUS='old',IOSTAT=ios)
  IF (ios /= 0) THEN
     CALL die("could not open GENIE control namelist file", &
          & __LINE__, __FILE__)
  END IF

  READ(UNIT=unitNum,NML=genie_control_nml,IOSTAT=ios)
  IF (ios /= 0) THEN
     CALL die('could not read GENIE control namelist', &
          & __LINE__, __FILE__)
  ELSE
     CLOSE(unitNum,IOSTAT=ios)
     CALL check_iostat(ios, __LINE__, __FILE__)
  END IF

  IF (debug_init > 1) CALL message("read values for genie_control_nml:", 3)
  IF (verbosity >= 3) WRITE (UNIT=6,NML=genie_control_nml)
  IF (debug_init > 1) CALL message("read namelist: genie_control_nml", 1)
END SUBROUTINE initialise_genie