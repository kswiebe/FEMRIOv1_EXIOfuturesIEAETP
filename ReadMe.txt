*************************************************************
FEMRIO v1.0: EXIOfuturesIEAETP
by Kirsten S. Wiebe   kswiebe@gmail.com
August 2018
***************************************************************


*************************************************************
FEMRIO Model 

F orward-looking
E nvironmentally-extended
M ulti-
R egional
I nput-
O utput
Model                                                        

FEMRIO Version 1.0  EXIOfuturesIEAETP
Historic data: EXIOBASE3
               https://doi.org/10.1111/jiec.12715
               http://www.exiobase.eu/
Scenario data: IEA Energy Technology Perspectives 2015
               http://www.iea.org/etp/etp2015/               
*************************************************************
                                                             
*************************************************************
This version is uploaded
- as a static version in a *.zip to 
  https://zenodo.org/communities/indecol/
- as a dynamic to build-on version to 
  https://github.com/kswiebe/FEMRIOv1_EXIOfuturesIEAETP/ 
  
To make the process of model development more transparent 
and open, future versions will be developed in R or Python
and the scripts will be available on GitHub from 
the start. Please feel free to use this and adapt it to your
needs, just make sure to cite our JECS paper below and refer 
to the doi from Zenodo or GitHub repository you used. 
*************************************************************


***************************************************************
A description and first analysis of this model is published in

Journal of Economic Structures (JECS)
https://journalofeconomicstructures.springeropen.com/
The Official Journal of the Pan-Pacific Association of 
Input-Output Studies (PAPAIOS)
Special Thematic Series on: 
Method development in EEIOA – novel advances and best practices

Title: 
Implementing exogenous scenarios in a global MRIO model for the 
estimation of future environmental footprints

Kirsten Svenja Wiebe kirsten.s.wiebe@ntnu.no
Eivind Lekve Bjelle eivind.bjelle@ntnu.no
Johannes Többen johannes.tobben@ntnu.no
Richard Wood richard.wood@ntnu.no

Industrial Ecology Programme, Department of Energy and Process 
Engineering, Norwegian University of Science and Technology, 
7491 Trondheim, Norway.                    
***************************************************************


***************************************************************
*************** MATLAB SCRIPTS OVERVIEW ***********************
***************************************************************

*************************************************************
I have tried to clean up the scripts as much as possible and 
also add explanations. I am very sure that I did not do a 
satisfactory job with this. Please feel free to contact me
if you have any questions or suggestions.
*************************************************************

************** LIMITATIONS ************************************
This directory contains almost everything you need to run the
model in Matlab, with 3 exceptions:
1) the full MRSUT EXIOBASE3 data which is on the NTNU servers
2) the original IEA EPT 2015 data (you need to buy it, sorry)
   for running the model, leave calculateEPT2015scendata = 0; 
3) the renewable energy technology coefficients for the
   scenarios. Please contact Dietmar Edler, DIW, or Ulrike Lehr,
   GWS, to get permission to use the original data they have
   collected for "Lehr U, Lutz C, Edler D, et al (2011) Kurz- 
   und langfristige Auswirkungen des Ausbaus der erneuerbaren 
   Energien auf den deutschen Arbeitsmarkt. Osnabrück". 
   For the model to run we have created a dummy data file,
   where the original coefficients are rounded to the first
   decimal: RawData\RenEnTechCoeff_round0.1.xlsx. We advise to 
   change this file according to your needs and revise the 
   coefficients based on the cofficients of the Machinery and 
   Equipment and the Electrical machinery etc. industries. 
Limitations 1) and 2) are not really limitations as we include
the data in our format (with the IEA ETP 2015 data sufficiently 
changed to make reverse engineering impossible). 
Limitation 3) has an influence on the results.  
***************************************************************



*************** MAIN ******************************************
The main files are
- EXIOfutures_part1_labourcoefficients.m (for information only)
- EXIOfutures_part2.m 
- EXIOfutures_part3_simpleanalysis.m 

These files call all other files and functions.
                                                
*************** PART 1: historic database *********************
EXIOfutures_part1_labourcoefficients.m needs to access the 
servers at NTNU to build the historical database. It is therefore 
only possible to run this script when connected to the network.
'_labourcoefficients' in the filename indicates that in this 
version we change the original EXIOBASE3 labour coefficients
in the electricity industries. This is based on the data from
Monetary_Labour_Input_Coefficients.xlsx in RawData.

The output of EXIOfutures_part1_labourcoefficients.m  is stored
in the folder EXIOhist. These files are input into 
EXIOfutures_part2.m.

*************** PART 2: forward looking model ****************** 
EXIOfutures_part2.m intializes the model and the scenario data 
and calls the EXIOfutures_projection.m script, that includes the
loop over years, for each scenario. More explanations are in the
script.


*************** PART 3: simple analysis ************************
EXIOfutures_part3_simpleanalysis.m calls the scripts
A1_Analysis_makeTradeData.m
A2_Analysis_makeData4Figures.m
that are used for the results displayed in the paper