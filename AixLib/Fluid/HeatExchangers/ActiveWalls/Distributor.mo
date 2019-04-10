within AixLib.Fluid.HeatExchangers.ActiveWalls;
model Distributor
  replaceable package Medium =
      Modelica.Media.Interfaces.PartialMedium
    "Medium in the component"                                                                  annotation(Dialog(group="Medium"),choicesAllMatching=true);
  parameter Integer n = 6 "Number of floor heating circuits";
  parameter Modelica.SIunits.Volume V=0.001 "Volume for numerical robustness";

  Modelica.Fluid.Interfaces.FluidPort_a mainFlow(redeclare package Medium =
        Medium)
    annotation (Placement(transformation(extent={{-70,20},{-50,40}})));

  Modelica.Fluid.Interfaces.FluidPort_b mainReturn(redeclare package Medium =
        Medium) annotation (Placement(transformation(extent={{-70,-40},{-50,-20}}),
        iconTransformation(extent={{-70,-40},{-50,-20}})));
  MixingVolumes.MixingVolume          vol_flow(
    redeclare package Medium = Medium,
    nPorts=n + 1,
    final V=V,
    m_flow_nominal=m_flow_nominal)
               annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=180,
        origin={0,10})));
  MixingVolumes.MixingVolume          vol_return(
    redeclare package Medium = Medium,
    nPorts=n + 1,
    final V=V,
    m_flow_nominal=m_flow_nominal)
               annotation (Placement(transformation(extent={{-10,-20},{10,0}},
          rotation=0)));
  Modelica.Fluid.Interfaces.FluidPorts_b flowPorts[n](redeclare each package
      Medium = Medium) annotation (Placement(
      visible=true,
      transformation(
        origin={0,60},
        extent={{-8,-18},{8,18}},
        rotation=90),
      iconTransformation(
        origin={0,60},
        extent={{-10,-10},{10,10}},
        rotation=0)));
  Modelica.Fluid.Interfaces.FluidPorts_a returnPorts[n](redeclare each package
      Medium = Medium) annotation (Placement(
      visible=true,
      transformation(
        origin={0,-59},
        extent={{-7,-18},{7,18}},
        rotation=90),
      iconTransformation(
        origin={0,-60},
        extent={{-10,-10},{10,10}},
        rotation=0)));
  parameter Modelica.SIunits.MassFlowRate m_flow_nominal
    "Nominal mass flow rate";
equation
  connect(mainFlow, vol_flow.ports[1]) annotation (Line(points={{-60,30},{-46,
          30},{-46,20},{3.55271e-15,20}}, color={255,0,0}));
  connect(mainReturn, vol_return.ports[1]) annotation (Line(points={{-60,-30},{
          -46,-30},{-46,-20},{0,-20}}, color={0,0,255}));

for k in 1:n loop
    connect(vol_flow.ports[k + 1], flowPorts[k])
      annotation (Line(points={{0,20},{0,60}}, color={255,0,0}));
    connect(vol_return.ports[k + 1], returnPorts[k])
      annotation (Line(points={{0,-20},{0,-59}}, color={0,0,255}));
end for;

  annotation (Diagram(coordinateSystem(preserveAspectRatio=true, extent={{-60,-60},
            {60,60}})),          Icon(coordinateSystem(preserveAspectRatio=true,
          extent={{-60,-60},{60,60}}),   graphics={
        Rectangle(
          extent={{-60,60},{60,-60}},
          lineColor={28,108,200},
          fillColor={255,255,255},
          fillPattern=FillPattern.Solid),
        Line(
          points={{-62,-30},{0,-30},{0,-68}},
          color={0,0,255},
          thickness=1),
        Line(
          points={{-62,28},{0,28},{0,60}},
          color={238,46,47},
          thickness=1),
        Text(
          extent={{-22,46},{72,36}},
          lineColor={28,108,200},
          fillColor={255,255,255},
          fillPattern=FillPattern.None,
          textString="[n] flow"),
        Text(
          extent={{-20,-30},{76,-40}},
          lineColor={28,108,200},
          fillColor={255,255,255},
          fillPattern=FillPattern.None,
          textString="[n] return")}),
    Documentation(revisions="<html>
<ul>
<li><i>January 11, 2019&nbsp;</i> by Fabian W&uuml;llhorst:<br/>
Make model more dynamic (See <a href=\"https://github.com/RWTH-EBC/AixLib/issues/673\">#673</a>)</li>
<li><i>June 15, 2017&nbsp;</i> by Tobias Blacha:<br/>
Moved into AixLib</li>
<li><i>November 06, 2014&nbsp;</i> by Ana Constantin:<br/>
Added documentation.</li>
</ul>
</html>",
        info="<html>
<h4><span style=\"color: #008000\">Overview</span></h4>
<p>Model for a contributor for different floor heating circuits in a house.</p>
<h4><span style=\"color: #008000\">Concept</span></h4>
<p>The contributor is built to connect <span style=\"font-family: Courier New;\">n</span> floor heating circuits together. The volume is used for nummerical reasons, to have a point where all the flows mix together. </p>
<h4><span style=\"color: #008000\">Example Results</span></h4>
<p><a href=\"AixLib.Fluid.HeatExchangers.Examples.ActiveWalls.ActiveWalls_Test\">AixLib.Fluid.HeatExchangers.Examples.ActiveWalls.ActiveWalls_Test</a></p>
</html>"));
end Distributor;
