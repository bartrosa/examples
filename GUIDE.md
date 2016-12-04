#Brief Guide
Here are some notes to assist in running the programs.

##Data Input
Most of the Fortran codes use a `namelist` to input a few parameters from standard input.
This gives an easy way to specify default values in the program itself, and to use a
keyword-based syntax to specify values different from the default ones at run-time.
The input file, or string, should usually begin with `&nml` and end with `/`.
As a minimum, the program will expect to read `&nml /` (an empty list), but to
change the parameters, typical input might be
```
&nml nblock=20, nstep=1000, dt=0.001 /
```
and the `key=value` pairs may be set out on different lines if you wish.

The program `md_nve_lj_vl` expects the input file to contain a second namelist,
`&nml_list`, which should either be empty or contain the desired value of `r_list_factor`.
See the file `verlet_list_module.f90` for details.

##Initial Configuration
Simulation runs require a starting configuration which can usually be prepared using
the `initialize` program (in `build_initialize/`).
The default parameters produce an FCC configuration of 256 atoms at reduced density &rho;=0.75,
writing out just the positions (for an MC program) to a file `cnf.inp`.
If the parameter `velocities=.true.` is supplied, then positions and velocities are
written to the file, corresponding to a reduced temperature _T_ = 1.0.
These values of &rho; and _T_ (see below) lie in the liquid region of the Lennard-Jones phase diagram.
Non-default values may, of course, be supplied for this or other models.
The `cnf.inp` file may then be copied to the directory in which the run is carried out.
Typically, runs produce a final configuration `cnf.out`
(which may be renamed to `cnf.inp` as a starting point for further runs)
and intermediate configurations `cnf.001`, `cnf.002` etc during the run.

A couple of utility programs are provided:
`adjust_energy` takes in an MD configuration and scales the velocities to
produce a configuration with a desired internal energy per atom, while
`adjust_density` takes in an MC or MD configuration
and scales the positions (and the box length) to produce a desired density.

##State points for different Lennard-Jones models
For most of the examples, we use a cutoff of _R_<sub>c</sub>=2.5&sigma;.
For MC programs the cut (but not shifted) potential (c) is used in the simulation,
while for MD programs the cut-and-shifted potential (cs) is used.
In all cases, an attempt is made to produce results without, and with, long-range corrections,
the latter giving an estimate for the full potential (f).
Differences between the different models are discussed in various places,
see e.g.

* A Trokhymchuk, J Alejandre, _J Chem Phys,_ __111,__ 8510 (1999).

Using their table V as a guide, we take the critical point to be roughly located at:

LJ model                 | _T_<sub>crit</sub> | &rho;<sub>crit</sub> | _P_<sub>crit</sub>
-----                    | ----               | ----                 | ----
f: full, with LRC        | 1.31               | 0.31                 | 0.13
c: cut (but not shifted) | 1.19               | 0.32                 | 0.11
cs: cut-and-shifted      | 1.08               | 0.32                 | 0.09

At any temperature below _T_<sub>crit</sub>, the liquid state is bounded below by the
liquid-gas coexistence density, and using Tables II-IV of the same reference as a guide,
we take the values for three example temperatures as

LJ model                 |  _T_ | &rho;<sub>L</sub> | _P_
-----                    | ---- |  ----             | ----
f: full, with LRC        |  0.8 | 0.793             | 0.005
c: cut (but not shifted) |  0.8 | 0.765             | 0.008
cs: cut-and-shifted      |  0.8 | 0.730             | 0.013

LJ model                 |  _T_ | &rho;<sub>L</sub> | _P_
-----                    | ---- |  ----             | ----
f: full, with LRC        |  0.9 | 0.746             | 0.012
c: cut (but not shifted) |  0.9 | 0.714             | 0.020
cs: cut-and-shifted      |  0.9 | 0.665             | 0.030

LJ model                 |  _T_ | &rho;<sub>L</sub> | _P_
-----                    | ---- |  ----             | ----
f: full, with LRC        |  1.0 | 0.695             | 0.026
c: cut (but not shifted) |  1.0 | 0.652             | 0.036
cs: cut-and-shifted      |  1.0 | 0.578             | 0.062

For Lennard-Jones, the state point (&rho;,_T_)=(0.75,1.0)
lies in the liquid region of the phase diagram for all these variants of the model.

Approximate equations of state for the full LJ potential have been presented by

* JK Johnson, JA Zollweg, KE Gubbins, _Mol Phys_, __78,__ 591 (1993)
* J Kolafa and I Nezbeda, _Fluid Phase Equil,_ __100,__ 1 (1994)
* M Mecke, A Muller, J Winkelmann, J Vrabec, J Fischer, R Span, W Wagner,
_Int J Thermophys,_ __17,__ 391 (1996) and __19,__ 1493(E) (1998)

For testing our programs we used the more recent fitted equations of state presented by

* M Thol, G Rutkai, R Span, J Vrabec and R Lustig, _Int J Thermophys,_ __36,__ 25 (2015)
* M Thol, G Rutkai, A Koester, R Lustig, R Span, J Vrabec, _J Phys Chem Ref Data,_ __45,__ 023101 (2016)

for both the cut-and-shifted potential (denoted cs below), at _R_<sub>c</sub>=2.5&sigma;,
and the full potential (denoted f).
The formulae are implemented in the supplied program `eos_lj`.
For completeness, note that Thol et al also supply C++ programs, and tables of data,
in the Supplementary Information associated with their papers.
They are not responsible for our (Fortran) program!

Here we compare with typical test runs from our programs using default parameters, _N_=256, except where stated.
Note that _E_ is the total internal energy per atom, including the ideal gas part,
and that _C<sub>v</sub>_ (per atom) and _P_ likewise include the ideal gas contributions.

Source | &rho;    | _T_ | _E_ (cs)  | _P_ (cs) | _C<sub>v</sub>_ (cs) | _E_ (f)   | _P_ (f)  | _C<sub>v</sub>_ (f)  
------ | -----    | -----     | --------  | -------- | --------- | -------   | -------  | --------
Thol et al (2015) (cs) | 0.75     | 1.00      | -2.9286   | 0.9897   |  2.2787   |           |          |          
Thol et al (2016) (f)  | 0.75     | 1.00      |           |          |           | -3.7212   | 0.3996   |  2.2630  
`bd_nvt_lj`            | 0.75     | 1.00      | -2.925(3) | 0.980(5) |  2.36(8)  | -3.725(3) | 0.379(5) |  2.37(8)
`md_nvt_lj`            | 0.75     | 1.00      | -2.993(3) | 0.965(6) |  2.08(11) | -3.733(3) | 0.363(6) |  2.09(12)
`md_npt_lj`            | 0.749(1) | 1.00      | -2.920(7) | 0.99     |           | -3.718(8) | 0.395(1) |
`md_nve_lj`            | 0.75     | 1.0023(2) | -2.9280   | 0.991(2) |  2.27(1)  | -3.7275   | 0.390(2) |          
`md_nve_lj_omp`        | 0.75     | 1.0029(1) | -2.9280   | 0.992(2) |  2.25(1)  | -3.7275   | 0.390(2) |          
`md_nve_lj_vl`         | 0.75     | 1.0030(2) | -2.9271   | 0.993(2) |  2.24(1)  | -3.7266   | 0.391(2) |          
`md_nve_lj_ll`&Dagger; | 0.75     | 1.0010(1) | -2.9278   | 0.990(2) |  2.28(1)  | -3.7274   | 0.389(2) |          
`smc_nvt_lj`           | 0.75     | 1.00      | -2.930(1) | 0.969(4) |  2.27(1)  | -3.729(1) | 0.367(4) |  2.27(1)

* &Dagger; indicates a larger system size, _N_=864.
* The `bd_nvt_lj` program seems to give a slightly high _C<sub>v</sub>_
* The `smc_nvt_lj` program seems to have a bug affecting multi-atom moves, needs fixing.
* The `md_nvt_lj` program seems to give a low _C<sub>v</sub>_, and low pressure, maybe needs looking at.
* The `md_npt_lj` program does not conserve well. Calculated _C<sub>p</sub>_ (cs)=4.2(2) while EOS gives 4.84.

Results for `md_lj_mts` are not directly comparable, because they use a larger cutoff (by default _Rc_=4.0&sigma;)
and hence a larger system. Here are the averages from a typical simulation, with _N_=400.

Source      | &rho; | _T_       | _E_ (cs)   | _P_ (cs) | _C<sub>v</sub>_ (cs) | _E_ (f)    | _P_ (f)
-------     | ----- | -------   | ---------  | -------- | --------- | -------    | -------
`md_lj_mts` | 0.75  | 1.0025(4) | -3.5230(5) | 0.551(2) | 2.27(1)   | -3.7188(5) | 0.404(2)

* With the default parameters, energy conservation of `md_lj_mts` is not great, with MSD average around 0.02. Perhaps needs looking at.

For the cut (but not shifted) potential, the value of _C<sub>v</sub>_ should be equal to the value for the full potential,
since the energy LRC is independent of temperature.
The Thol et al (2016) EOS is for the full potential
is used to predict results for the cut (but not shifted) potential (denoted c),
at _R_<sub>c</sub>=2.5&sigma;, using the same LRC and delta corrections as in the MC codes.

Source                 | &rho;     | _T_   | _E_ (c)    | _P_ (c)  | _E_ (f)    | _P_ (f)  | _C<sub>v</sub>_ (f)
------                 | -----     | ----- | -------    | -------  | -------    | -------  | --------
Thol et al (2016) (f)  | 0.75      | 1.00  | -3.3197    | 0.7008   | -3.7212    | 0.3996   |  2.2630  
`mc_nvt_lj`            | 0.75      | 1.00  | -3.332(1)  | 0.651(3) | -3.734(1)  | 0.350(3) |  2.28(1)
`mc_nvt_lj_re`         | 0.75      | 1.00  | -3.332(1)  | 0.648(2) | -3.734(1)  | 0.347(2) |  2.258(4)
`mc_nvt_lj_ll`&Dagger; | 0.75      | 1.00  | -3.3230(3) | 0.669(1) | -3.7246(3) | 0.367(1) |  2.27(1)
`mc_npt_lj`            | 0.7501(2) | 1.00  | -3.331(1)  | 0.69     | -3.733(1)  | 0.364(2) |          
`mc_npt_lj_ll`&Dagger; | 0.7506(4) | 1.00  | -3.332(3)  | 0.69     | -3.734(3)  | 0.358(3) |          
`mc_zvt_lj`            | 0.7504(4) | 1.00  | -3.333(3)  | 0.668(4) | -3.735(3)  | 0.366(4) |          
`mc_zvt_lj_ll`&Dagger; | 0.7501(3) | 1.00  | -3.328(2)  | 0.669(2) | -3.729(2)  | 0.368(2) |          

* &Dagger; indicates a larger system size, _N_=864 (or approximately so for `mc_zvt_lj_ll`)
* The `mc_nvt_lj` program seems to give a low pressure, needs investigating.
* The `mc_nvt_lj_re` program was run for four temperatures, see below for details.
* The `mc_npt_lj` measured pressure (c) is 0.666(2) which is a little low.
Measured _C<sub>p</sub>_ (full) is 5.28(7) compared with Thol et al (2016) EOS giving 5.22
* The `mc_npt_lj_ll` program was run with `db_max`=0.015 to give a volume acceptance ratio around 9%.
Measured pressure (c) is 0.660(3) which is again a little low. Is the delta correction wrong somehow?
Measured _C<sub>p</sub>_ (full) is 5.04(16) compared with Thol et al (2016) EOS value of 5.22.
The program probably needs making more resilient against changes in box size.
* The `mc_zvt_lj` program was run at activity _z_=0.0795, the default value in the program, in a box of length 7&sigma;.
The Thol et al (2016) LRC-corrected value to give &rho;=0.75 would be _z_=0.080627.
Acceptance rate of creation/destruction moves is quite small, at about 0.3%.
For other state points see below.
* The `mc_zvt_lj_ll` program has the same acceptance ratio of moves.
It seems to run very slowly, which needs looking into.

Tests for the grand canonical MC program were initially conducted at a slightly lower density,
very close to the liquid-vapour coexistence line (see Gibbs simulations below).
A box length of 7&sigma; was used, and creation/destruction acceptance ratios were around 1.5%.
Comparison was made with the Thol et al (2016) equation of state, with corrections for the cutoff.
The corresponding density is lower than the liquid coexistence density for the full potential,
so there is no guarantee that the EOS will be accurate
(it is only fitted in the single-phase regions of the full potential).

Source                |  z     | &rho;     | _T_  | _E_ (c)   | _P_ (c)    | _E_ (f)   | _P_ (f)  
-------               | ----   | -----     | ---- | --------- | -------    | -------   | -------  
Thol et al (2016) (c) | 0.032  | 0.65325   | 1.0  | -2.7212   | 0.0457     | -3.0710   | -0.1828  
`mc_zvt_lj`           | 0.032  | 0.6532(5) | 1.0  | -2.728(3) | 0.0325(25) | -3.078(4) | -0.196(2)

##Brownian dynamics program
The program `bd_nvt_lj` carries out a Brownian dynamics simulation for a set of atoms
interacting through the cut-and-shifted Lennard-Jones potential.
An initial configuration may be prepared, at a typical Lennard-Jones state point,
using the `initialize` program in the usual way.
As well as the usual run parameters, similar to a molecular dynamics code,
the user specifies a friction coefficient.
The calculated average thermodynamic quantities should be as expected for an
equilibrium simulation of this model at the chosen state point (see e.g. the table above).

##Gibbs Monte Carlo program
The program `mc_gibbs_lj` carries out Gibbs ensemble Monte Carlo,
and to test it we selected a temperature _T_=1.0,
which is below the critical point for the cut (but not shifted) LJ potential
(see tables above).
It was found convenient to start from a lower temperature,
with configurations at gas and liquid densities, with roughly equal numbers of particles,
and slowly work upwards in temperature, to equilibrate.
Note that the program expects two starting configurations: cnf1.inp and cnf2.inp.
Exchanges of box identity are expected as the critical temperature is approached,
and so one should not place blind trust in the separate box averages reported by the program,
but refer to histograms of density, energy etc.
At _T_=1.0, however, these exchanges of box identity are quite infrequent,
and the averages corresponded well to literature values for the coexistence parameters.
The production run corresponded to default parameters in the program.

Source  | &rho;<sub>L</sub> | &rho;<sub>G</sub> | _P_<sub>L</sub> | _P_<sub>G</sub> | _E_<sub>L</sub> (c) | _E_<sub>G</sub> (c)
------- | -------- | -------- | -------  | -------- | --------------  | --------------
Trokhymchuk et al MC | 0.6542   | 0.0439   | 0.0336   | 0.0336   |                 |
Trokhymchuk et al MD | 0.6507   | 0.0500   | 0.0380   | 0.0380   | -2.713 &Dagger; | 1.047 &Dagger;
`mc_gibbs_lj`        | 0.652(1) | 0.050(1) | 0.028(1) | 0.038(1) | -2.730(5)       | 1.054(8)

* There is a small discrepancy between pressures in the two boxes.
* &Dagger; indicates values for given &rho; and _T_ from the Thol et al (2016) EOS (f) with cutoff correction.

##Replica exchange program
The `mc_nvt_lj_re` program conducts runs at several temperatures: four were used in testing.
The default program values include _T_=1.0, which is reported above, and here is the complete set,
with expected values from the Thol et al (2016) equation of state (f) corrected for cutoff.
As usual the program employed the cut (but not shifted) potential.
All runs are for density &rho;=0.75.
At the lowest temperature, the full-potential system would lie in the coexistence region.

Source                 | _T_    | _E_ (c)   | _P_ (c)  | _E_ (f)   | _P_ (f)   | _C<sub>v</sub>_ (f)
------                 | -----  | -------   | -------  | -------   | -------   | --------
Thol et al (2016) (f)  | 0.8772 | -3.6001   | 0.1942   | -4.0017   | -0.1070   |  2.3081  
`mc_nvt_lj_re`         | 0.8772 | -3.613(1) | 0.140(2) | -4.014(1) | -0.161(2) |  2.31(1)
Thol et al (2016) (f)  | 1.0000 | -3.3197   | 0.7008   | -3.7212   | 0.3996    |  2.2630  
`mc_nvt_lj_re`         | 1.0000 | -3.332(1) | 0.648(2) | -3.734(1) |  0.347(2) |  2.258(4)
Thol et al (2016) (f)  | 1.1400 | -3.0055   | 1.2571   | -3.4070   |  0.9559   |  2.2278  
`mc_nvt_lj_re`         | 1.1400 | -3.016(1) | 1.212(2) | -3.417(1) |  0.911(2) |  2.233(4)
Thol et al (2016) (f)  | 1.2996 | -2.6523   | 1.8667   | -3.0539   |  1.5655   |  2.1989  
`mc_nvt_lj_re`         | 1.2996 | -2.662(1) | 1.820(3) | -3.063(1) |  1.519(3) |  2.214(5)

##Chain simulation programs
The program `mc_chain_nvt_cbmc_lj` simulates a single Lennard-Jones chain,
where the atoms are linked by harmonic springs.
There are, therefore,
both bonded and non-bonded interactions,
the former being used to select atom positions,
and the latter appearing in Rosenbluth weights,
which govern the acceptance/rejection of moves.
For comparison with the paper of Calvo, Doye and Wales, _J Chem Phys,_ __116,__ 2642 (2002),
test runs were carried out using _N_=13 atoms, a bond length of 1.122462&sigma;
(prepared using `build_initialize/initialize` with random non-overlapping atom positions)
and a rather low spring potential _k_<sub>spring</sub>=20 (the program default is 400).
We only use CBMC moves in this code: for a practical application it would be advisable
to include other kinds of move, for example crankshaft, pivot, and bridging moves.
Replica exchange (as used by Calvo et al) would also improve the sampling at low temperature.
Below we report the excess, potential, energy per atom _PE_,
and the excess heat capacity per atom _C<sub>v</sub>_(ex),
as well as the radius of gyration _R_<sub>g</sub>.
The program default run length is 10 blocks of 100000 steps.

_T_   | _PE_ | _R_<sub>g</sub> | _C<sub>v</sub>_(ex)
----- | ------    | ------   | ------
0.40  | -1.50(1)  | 1.173(3) | 2.51(17)
0.45  | -1.40(1)  | 1.201(3) | 2.26(8)
0.50  | -1.291(8) | 1.226(2) | 1.85(5)

For lower temperatures (below), longer runs (10 blocks of 1000000 steps) were used.

_T_   | _PE_ | _R_<sub>g</sub> | _C<sub>v</sub>_(ex)
----- | ------    | ------    | ------
0.26  | -2.044(7) | 1.074(1)  | 3.3(2)
0.28  | -1.967(5) | 1.086(1)  | 4.16(9)
0.29  | -1.905(4) | 1.096(1)  | 4.6(1)
0.30  | -1.893(7) | 1.098(1)  | 4.71(9)
0.31  | -1.819(3) | 1.1105(8) | 4.34(6)
0.32  | -1.789(2) | 1.1162(5) | 4.2(1 )
0.33  | -1.742(3) | 1.1254(5) | 4.05(1)
0.34  | -1.705(4) | 1.133(1)  | 3.7(1)
0.35  | -1.672(3) | 1.140(1)  | 3.49(8)

At the lowest temperatures, the acceptance rate of CBMC moves (with the default parameters) was around 2%,
while at _T_=0.35 it was around 11%, increasing further at higher temperatures.
The results are broadly in agreement with Calvo et al (2002) showing a similar sized peak in _C<sub>v</sub>_,
although at a somewhat lower temperature (0.30 as opposed to 0.35).

For the hard-sphere square-well chain, the aim was to show the operation of the Wang-Landau method.
Here we used pivot and crankshaft moves as well as CBMC regrowth.
In a practical application it would be advisable to include some bridging moves as well.
Reasonably long chains have been studied by Taylor, Paul and Binder, _J Chem Phys,_ __131,__ 114907 (2009),
who provide references to earlier simulation work, as well as exact results for very short chains.
Here we choose _N_=13, bond length equal to &sigma;, and a nonbonded interaction range of 1.5&sigma;.
The starting chain configuration can be prepared using `build_initialize/initialize` in the usual way.

As a reference for comparison, we ran a set of canonical ensemble calculations with `mc_chain_nvt_sw`.
The program default is to run for 10 blocks, each of 100000 steps;
this was increased to 10 blocks of 500000 steps for temperatures below 0.25.
The results are shown on the left of the following table.

_T_   |  _PE_ | _R_<sub>g</sub> | _C<sub>v</sub>_(ex) | _PE_ | _R_<sub>g</sub> | _C<sub>v</sub>_(ex)
----- | ------    | ------    | ------     | ------  | ------ | ------
0.15  | -2.81(1)  |  1.070(2) |  1.1(2)    | -2.814  |  1.068 |  2.053
0.18  | -2.759(8) |  1.072(2) |  2.2(2)    | -2.744  |  1.073 |  2.498
0.20  | -2.699(8) |  1.077(2) |  2.4(1)    | -2.694  |  1.078 |  2.366
0.22  | -2.645(4) |  1.082(1) |  2.16(7)   | -2.649  |  1.082 |  2.226
0.25  | -2.586(8) |  1.090(2) |  2.15(9)   | -2.584  |  1.089 |  2.121
0.30  | -2.482(6) |  1.104(2) |  1.97(6)   | -2.481  |  1.103 |  2.010
0.50  | -2.127(2) |  1.161(1) |  1.50(2)   | -2.128  |  1.161 |  1.491
1.00  | -1.547(2) |  1.318(1) |  1.024(6)  | -1.543  |  1.319 |  1.020
2.00  | -0.885(1) |  1.658(1) |  0.330(2)  | -0.883  |  1.660 |  0.332
5.00  | -0.566(1) |  1.889(1) |  0.0318(1) | -0.565  |  1.890 |  0.032

Results obtained from a run of the Wang-Landau program `mc_chain_wl_sw`,
using the same model, are given on the right of the table above.
The program was run with default parameters:
the flatness criterion was set at 80% and there were 20 stages during which the entropy
modification constant `ds` was halved at each stage.
The results are from the histograms produced in the 20th stage.
This analysis can also be performed (for any desired temperature) by the program `wl_hist`, after the run.
The results are generally in good agreement with the canonical ensemble test runs.
The most significant discrepancies are in the heat capacities at the lowest two temperatures,
which reflects the poor sampling of the canonical ensemble program (with these basic MC moves),
and (probably to a lesser extent) the sampling problems about to be discussed.

This particular test run illustrated one drawback of the simplest Wang-Landau implementation:
two low-lying energies (corresponding to _q_=38 and 39 square-well interactions) were discovered
during the very last stage, in which `ds` is very small.
Accordingly, the system remained stuck in these low-energy states for a very long time,
until their tabulated entropy _s(q)_ reached a high enough value to allow _q_ to change;
even then, the final weight of the lowest state in the final "flat" histogram
could not be considered completely reliable.
The overall run length was of order 90000 blocks of 10000 steps each,
most of it spent in stage 20.

If the run were repeated with the same parameters,
one cannot guarantee that the same result will be obtained:
indeed, it is more likely that the run would conclude much earlier, within a few thousand blocks,
without ever discovering these low-lying energies.
This would affect the results, particularly at the lower temperatures,
and of course there would be no indication of anything wrong.
It is always a danger with any Monte Carlo method, including Wang-Landau,
that inaccessible configurations will not be sampled.
Various improvements of the method may be found in the literature.
(The reader is invited to work out the structure of the 13-atom chain configuration
with hard sphere diameter and bond length both equal to &sigma;
having 39 nonbonded interactions within range 1.5&sigma;.
_Hint:_ it is not one of the highest-symmetry clusters such as the icosahedron;
however, it is based on a fairly symmetric cluster,
with small distortions due to the fixed bond length and the need to maximise interactions.)

* We might consider adding a fixed-length production run at the end of `mc_chain_wl_sw`.

##Cluster program
The `cluster` program is self contained. It reads in a configuration of atomic positions
and produces a circular linked list for each cluster identified within it.
The best value of the critical separation `r_cl` depends on the particular physical system
being considered. The supplied default will, for a liquid-state Lennard-Jones configuration,
most likely identify almost all atoms as belonging to a single cluster, with at most
a few atoms being isolated on their own. However, this is unlikely to be the type of system
for which this analysis is useful.

##Correlation function program
The aim of the program `corfun` is to illustrate the direct method, and the FFT method,
for calculating time correlation functions.
The program is self contained: it generates the time dependent data itself,
using a generalized Langevin equation,
for which the time correlation function is known.
The default parameters produce a damped, oscillatory, correlation function,
but these can be adjusted to give monotonic decay,
or to make the oscillations more prominent.
If the `origin_interval` parameter is left at its default value of 1,
then the direct and FFT methods should agree with each other to within numerical precision.
The efficiency of the direct method may be improved,
by selecting origins less frequently,
and in this case the results obtained by the two methods may differ a little.

##Diffusion program
The program `diffusion` reads in a sequence of configurations and calculates
the velocity auto correlation function, the mean square displacement, and
the cross-correlation between velocity and displacement.
Any of these may be used to estimate the diffusion coefficient,
as described in the text.
The output appears in `diffusion.out`
It is instructive to plot all three curves vs time.

The input trajectory is handled in a crude way,
by reading in successive snapshots with filenames `cnf.000`, `cnf.001`, etc.
These might be produced by a molecular dynamics program,
at the end of each block,
choosing to make the blocks fairly small (perhaps 10 steps).
As written, the program will only handle up to `cnf.999`.
Obviously, in a practical application,
a proper trajectory file would be used instead of these separate files.

It is up to the user to provide the time interval between successive configurations.
This will typically be a small multiple of the timestep used in the original simulation.
This value `delta` is only used to calculate the time, in the first column of
the output file.
A default value of 1 is provided as a place-holder, but
the user really should specify a physically meaningful value;
forgetting to do so could cause confusion when one attempts
to quantify the results.

To make it easier to test this program,
we have also supplied a self-contained program `diffusion_test`,
which generates an appropriate trajectory by numerically solving
the simple Langevin equation for _N_ non-interacting atoms.
For this model, one specifies the temperature and friction coefficient,
which dictates the rate of exponential decay of the vacf,
and hence the diffusion coefficient.

##DPD program
For the `dpd` example, we recommend generating an initial configuration
using the `initialize` program (in `build_initialize/`), with the
following namelist input
```
&nml n = 100, density = 3.0, random_positions = .true., velocities = .true. /
```
The value of the density is typical when using this method to model water.
The approximate DPD equation of state is used to estimate the pressure,
at the chosen density, temperature, and interaction strength, for comparison.
This is expected to become inaccurate for densities lower than about 2.

##Error calculation
The program `error_calc` is a self-contained illustration of the effects of
correlations on the estimation of errors for a time series.
We produce the series using a generalized Langevin equation,
in the same manner as for the correlation function program (see above).
Since the correlation time of the GLE is exactly known,
we can predict the effects, and compare with the empirical estimates
obtained by different methods.
The program contains extensive comments to explain what is being calculated at each stage.

##FFT program
The aim of `fft3dwrap` is to illustrate the way a standard Fast Fourier Transform
library routine is wrapped in a user program.
We numerically transform a 3D Gaussian function,
and compare with the analytically, exactly, known result,
User input defines the number of grid points and the box size;
sensible defaults are provided.
The library that we use for this example is [FFTW](http://www.fftw.org/).

##Hit-and-miss and sample-mean
The two programs `hit_and_miss` and `sample_mean` illustrate two very simple
Monte Carlo methods to estimate the volume of a 3D object.
They are both described in detail at the start of Chapter 4.
No user input is required.
For the built-in values defining the geometry, the exact result is 5/3.