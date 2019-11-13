within AixLib.ThermalZones.HighOrder.Components.MoistAir;
model VarMoistAirExchange
  "Heat and moisture flow caused by air exchange"
  extends Modelica.Thermal.HeatTransfer.Interfaces.Element1D;
  parameter Modelica.SIunits.Volume V = 50 "Volume of the room";
  parameter Modelica.SIunits.SpecificHeatCapacity c = 1000
    "Specific heat capacity of air";
  parameter Modelica.SIunits.Density rho = 1.25 "Air density";
  Modelica.Blocks.Interfaces.RealInput InPort1 annotation(Placement(transformation(extent = {{-100, -54}, {-80, -74}})));
  Modelica.Blocks.Interfaces.RealOutput QLat_flow
    annotation (Placement(transformation(extent={{94,-72},{114,-52}})));
  Modelica.Blocks.Interfaces.RealInput HumIn(
    final quantity="MassFraction",
    final unit="kg/kg",
    min=0)
    "absolute humidity of ventilation air"
    annotation (Placement(transformation(extent={{-100,-60},{-80,-40}})));
  Modelica.Blocks.Interfaces.RealInput HumOut(
    final quantity="MassFraction",
    final unit="kg/kg",
    min=0) "absolute humidity of room air"
    annotation (Placement(transformation(extent={{100,42},{80,62}})));
protected
  constant Modelica.SIunits.SpecificEnthalpy enthalpyOfEvaporation = AixLib.Utilities.Psychrometrics.Constants.h_fg
    "enthalpy of evaporation";
  constant Modelica.SIunits.SpecificHeatCapacity cp_steam = AixLib.Utilities.Psychrometrics.Constants.cpSte
    "specific heat capacity of steam";
   constant Modelica.SIunits.SpecificEnergy h_fg=
    Media.Air.enthalpyOfCondensingGas(273.15+37) "Latent heat of water vapor";
equation
   port_a.Q_flow = InPort1 * V * c * rho * (port_a.T - port_b.T) / 3600;
   QLat_flow = InPort1 * V * rho * (HumIn-HumOut) / 3600 * h_fg;
  annotation (Documentation(info="<html>
 <h4><font color=\"#008000\">Overview</font></h4>
 <p>The <b>VarMoistAirExchange</b> model describes heat and moisture transfer by air exchange (e.g. due to opening a window). It needs the air exchange rate (in <img src=\"modelica://AixLib/Resources/Images/Building/Components/DryAir/VarAirExchange/equation-fHlz87wz.png\" alt=\"h^(-1)\"/>) as input value. </p>
 </html>", revisions="<html>
 <ul>
 <li>July, 2019, by Martin Kremer:<br/>Adding latent heat output of moisture, since ventilation moisture is already gaseous.</li>
 <li>April, 2019, by Martin Kremer:<br/>First Implementation.</li>
 </ul>
</html>"),
    Diagram(graphics={                                                                                                            Rectangle(extent = {{-80, 60}, {80, -100}}, lineColor = {0, 0, 0}), Rectangle(extent = {{-80, 60}, {80, -100}}, lineColor = {0, 0, 0}), Rectangle(extent = {{-80, 60}, {80, -100}}, lineColor = {0, 0, 0}), Rectangle(extent = {{-80, 60}, {80, -100}}, lineColor = {0, 0, 0}, fillColor = {211, 243, 255},
            fillPattern =                                                                                                   FillPattern.Solid), Polygon(points = {{60, -58}, {30, -72}, {-22, -68}, {-16, -60}, {-68, -52}, {-30, -80}, {-24, -74}, {46, -74}, {60, -58}}, lineColor = {0, 0, 0}, smooth = Smooth.Bezier, fillColor = {255, 255, 255},
            fillPattern =                                                                                                   FillPattern.Solid), Text(extent = {{-30, 16}, {30, -50}}, lineColor = {0, 0, 0}, fillColor = {255, 255, 255},
            fillPattern =                                                                                                   FillPattern.Solid, textString = "Air"), Polygon(points = {{-58, 22}, {-28, 36}, {24, 32}, {18, 24}, {70, 16}, {32, 44}, {26, 38}, {-44, 38}, {-58, 22}}, lineColor = {0, 0, 0}, smooth = Smooth.Bezier, fillColor = {255, 255, 255},
            fillPattern =                                                                                                   FillPattern.Solid)}),
    Icon(graphics={                                                                                                               Rectangle(extent = {{-80, 60}, {80, -100}}, lineColor = {0, 0, 0}), Rectangle(extent = {{-80, 60}, {80, -100}}, lineColor = {0, 0, 0}), Rectangle(extent = {{-80, 60}, {80, -100}}, lineColor = {0, 0, 0}), Rectangle(extent = {{-80, 60}, {80, -100}}, lineColor = {0, 0, 0}, fillColor = {211, 243, 255},
            fillPattern =                                                                                                   FillPattern.Solid), Polygon(points = {{60, -58}, {30, -72}, {-22, -68}, {-16, -60}, {-68, -52}, {-30, -80}, {-24, -74}, {46, -74}, {60, -58}}, lineColor = {0, 0, 0}, smooth = Smooth.Bezier, fillColor = {255, 255, 255},
            fillPattern =                                                                                                   FillPattern.Solid), Text(extent = {{-30, 16}, {30, -50}}, lineColor = {0, 0, 0}, fillColor = {255, 255, 255},
            fillPattern =                                                                                                   FillPattern.Solid, textString = "Air"), Polygon(points = {{-58, 22}, {-28, 36}, {24, 32}, {18, 24}, {70, 16}, {32, 44}, {26, 38}, {-44, 38}, {-58, 22}}, lineColor = {0, 0, 0}, smooth = Smooth.Bezier, fillColor = {255, 255, 255},
            fillPattern =                                                                                                   FillPattern.Solid)}));
end VarMoistAirExchange;
