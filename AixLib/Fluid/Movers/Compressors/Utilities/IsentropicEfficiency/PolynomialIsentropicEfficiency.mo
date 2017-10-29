within AixLib.Fluid.Movers.Compressors.Utilities.IsentropicEfficiency;
model PolynomialIsentropicEfficiency
  "Model describing isentropic efficiency based on polynomial approach"
  extends PartialIsentropicEfficiency;

  // Definition of parameters describing polynomial approaches in general
  //
  parameter Types.IsentropicPolynomialModels polyMod=Types.IsentropicPolynomialModels.Karlsson2007
    "Chose predefined polynomial model for flow coefficient"
    annotation (Dialog(group="Modelling approach"));
  parameter Real a[:]
    "Multiplication factors for each summand"
    annotation(Dialog(group="Modelling approach"));
  parameter Real b[:]
    "Exponents for each summand"
    annotation(Dialog(group="Modelling approach"));
  parameter Integer nT = size(a,1)
    "Number of terms used for the calculation procedure"
    annotation(Dialog(group="Modelling approach",
                      enable=false));

  // Definition of parameters describing specific approaches
  //
  parameter Real c[:] = {1}
    "Coefficients used for correction factors if needed"
    annotation(Dialog(group="Modelling approach"));
  parameter Modelica.SIunits.Frequency rotSpeRef = 9.334
    "Reference rotational speed"
    annotation(Dialog(group="Reference properties"));

  // Definition of coefficients
  //
  Real p[nT]
    "Array that contains all coefficients used for the calculation procedure";
  Real corFac[2]
    "Array of correction factors used if efficiency model proposed in literature
    differs from efficiency model defined in PartialCompressor model";

equation
  // Calculation of coefficients
  //
  if (polyMod == Types.IsentropicPolynomialModels.DarrAndCrawford1992) then
    /*Polynomial approach presented by Dar and Crawford (1992):
      etaIse = a1 + a2*rotSpe +a3/dInl
      
      Caution with units - In the following, none S.I units are presented:
      Density:           in lb/ft^3
      Rotational Speed:  in rpm
      Volume flow:       in ft^3/min
    */
    p[1] = 1
      "Dummy value for usage of simple coefficcient";
    p[2] = rotSpe*60
      "Rotational speed";
    p[3] = 1/(Medium.density(staInl)*0.3048^3/0.453592)
      "Effect of clearance";

    corFac = {1,1}
      "No correction factors are needed";

  elseif (polyMod == Types.IsentropicPolynomialModels.Karlsson2007) then
    /*Polynomial approach presented by Karlsson (2007):
      etaIse = a1 + a2*piPre + a3*piPre^2 + a4*rotSpe + a5*rotSpe^2
      
      Caution with units - In the following, none S.I units are presented:
      Pressure:            in bar
    */
    p[1] = 1
      "Usage of dummy value for simple coefficient";
    p[2] = piPre
      "Pressure ratio";
    p[3] = piPre^2
      "Quadratic pressure ratio";
    p[4] = rotSpe
      "Rotational speed";
    p[5] = rotSpe^2
      "Quadratic rotational speed";

    corFac = {1,1}
      "No correction factors are needed";

  else
    assert(false, "Invalid choice of polynomial approach");
  end if;

  // Calculationg of flow coefficient
  //
  etaIse = min(1, corFac[1] *
    sum(a[i]*p[i]^b[i] for i in 1:nT)^corFac[2])
    "Calculation procedure of general polynomial";

  annotation (Documentation(revisions="<html>
<ul>
  <li>
  October 20, 2017, by Mirko Engelpracht:<br/>
  First implementation
  (see <a href=\"https://github.com/RWTH-EBC/AixLib/issues/467\">issue 467</a>).
  </li>
</ul>
</html>"));
end PolynomialIsentropicEfficiency;
