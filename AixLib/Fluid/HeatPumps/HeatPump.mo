﻿within AixLib.Fluid.HeatPumps;
model HeatPump "Grey-box heat pump model using a black-box to simulate the refrigeration cycle"
  extends AixLib.Fluid.Interfaces.PartialFourPortInterface(
    redeclare final package Medium1 = Medium_con,
    redeclare final package Medium2 = Medium_eva,
    final m1_flow_nominal=mFlow_conNominal,
    final m2_flow_nominal=mFlow_evaNominal,
    final allowFlowReversal1=allowFlowReversalCon,
    final allowFlowReversal2=allowFlowReversalEva,
    final m1_flow_small=1E-4*abs(mFlow_conNominal),
    final m2_flow_small=1E-4*abs(mFlow_evaNominal),
    final show_T=show_TPort);

//General
  replaceable package Medium_con = 
    Modelica.Media.Interfaces.PartialMedium "Medium at sink side"
    annotation (Dialog(tab = "Condenser"),choicesAllMatching=true);
  replaceable package Medium_eva = 
    Modelica.Media.Interfaces.PartialMedium "Medium at source side"
    annotation (Dialog(tab = "Evaporator"),choicesAllMatching=true);
  parameter Boolean use_revHP=true "True if the HP is reversible" annotation(choices(choice=true "reversible HP",
      choice=false "only heating",
      radioButtons=true), Dialog(descriptionLabel=true));
  replaceable model PerDataHea =
      AixLib.Fluid.HeatPumps.BaseClasses.PerformanceData.BaseClasses.PartialPerformanceData
  "Performance data of HP in heating mode"
    annotation (choicesAllMatching=true);
  replaceable model PerDataChi =
      AixLib.Fluid.HeatPumps.BaseClasses.PerformanceData.BaseClasses.PartialPerformanceData
  "Performance data of HP in chilling mode"
    annotation (Dialog(enable=use_revHP),choicesAllMatching=true);

  parameter Real scalingFactor=1 "Scaling-factor of HP";
  parameter Boolean use_refIne=true
    "Consider the inertia of the refrigerant cycle"                           annotation(choices(checkBox=true), Dialog(
        group="Refrigerant inertia"));

  parameter Modelica.SIunits.Frequency refIneFre_constant
    "Cut off frequency for inertia of refrigerant cycle"
    annotation (Dialog(enable=use_refIne, group="Refrigerant inertia"),Evaluate=true);
  parameter Integer nthOrder=3 "Order of refrigerant cycle interia" annotation (Dialog(enable=
          use_refIne, group="Refrigerant inertia"));

//Condenser
  parameter Modelica.SIunits.MassFlowRate mFlow_conNominal
    "Nominal mass flow rate"
    annotation (Dialog(group="Parameters", tab="Condenser"),Evaluate=true);
  parameter Modelica.SIunits.Volume VCon "Volume in condenser"
    annotation (Evaluate=true,Dialog(group="Parameters", tab="Condenser"));
  parameter Modelica.SIunits.PressureDifference dpCon_nominal
    "Pressure drop at nominal mass flow rate"
    annotation (Dialog(group="Flow resistance", tab="Condenser"), Evaluate=true);
  parameter Real deltaM_con=0.1
    "Fraction of nominal mass flow rate where transition to turbulent occurs"
    annotation (Dialog(tab="Condenser", group="Flow resistance"));
  parameter Boolean use_conCap=true
    "If heat losses at capacitor side are considered or not"
    annotation (Dialog(group="Heat Losses", tab="Condenser"),
                                          choices(checkBox=true));
  parameter Modelica.SIunits.HeatCapacity CCon
    "Heat capacity of Condenser (= cp*m)" annotation (Evaluate=true,Dialog(group="Heat Losses",
        tab="Condenser",
      enable=use_conCap));
  parameter Modelica.SIunits.ThermalConductance GConOut
    "Constant parameter for heat transfer to the ambient. Represents a sum of thermal resistances such as conductance, insulation and natural convection"
    annotation (Evaluate=true,Dialog(group="Heat Losses", tab="Condenser",
      enable=use_conCap));
  parameter Modelica.SIunits.ThermalConductance GConIns
    "Constant parameter for heat transfer to heat exchangers capacity. Represents a sum of thermal resistances such as forced convection and conduction inside of the capacity"
    annotation (Evaluate=true,Dialog(group="Heat Losses", tab="Condenser",
      enable=use_conCap));
//Evaporator
  parameter Modelica.SIunits.MassFlowRate mFlow_evaNominal
    "Nominal mass flow rate" annotation (Dialog(group="Parameters", tab="Evaporator"),Evaluate=true);

  parameter Modelica.SIunits.Volume VEva "Volume in evaporator"
    annotation (Evaluate=true,Dialog(group="Parameters", tab="Evaporator"));
  parameter Modelica.SIunits.PressureDifference dpEva_nominal
    "Pressure drop at nominal mass flow rate"
    annotation (Dialog(group="Flow resistance", tab="Evaporator"),Evaluate=true);
  parameter Real deltaM_eva=0.1
    "Fraction of nominal mass flow rate where transition to turbulent occurs"
    annotation (Dialog(tab="Evaporator", group="Flow resistance"));
  parameter Boolean use_evaCap=true
    "If heat losses at capacitor side are considered or not"
    annotation (Dialog(group="Heat Losses", tab="Evaporator"),
                                          choices(checkBox=true));
  parameter Modelica.SIunits.HeatCapacity CEva
    "Heat capacity of Evaporator (= cp*m)"
    annotation (Evaluate=true,Dialog(group="Heat Losses", tab="Evaporator",
      enable=use_evaCap));
  parameter Modelica.SIunits.ThermalConductance GEvaOut
    "Constant parameter for heat transfer to the ambient. Represents a sum of thermal resistances such as conductance, insulation and natural convection"
    annotation (Evaluate=true,Dialog(group="Heat Losses", tab="Evaporator",
      enable=use_evaCap));
  parameter Modelica.SIunits.ThermalConductance GEvaIns
    "Constant parameter for heat transfer to heat exchangers capacity. Represents a sum of thermal resistances such as forced convection and conduction inside of the capacity"
    annotation (Evaluate=true,Dialog(group="Heat Losses", tab="Evaporator",
      enable=use_evaCap));
//Assumptions
  parameter Modelica.SIunits.Time tauSenT=1
    "Time constant at nominal flow rate (use tau=0 for steady-state sensor, but see user guide for potential problems)"
    annotation (Dialog(tab="Assumptions", group="Temperature sensors"));

  parameter Boolean transferHeat=true
    "If true, temperature T converges towards TAmb when no flow"
    annotation (Dialog(tab="Assumptions", group="Temperature sensors"),choices(checkBox=true));
  parameter Boolean allowFlowReversalEva=true
    "= false to simplify equations, assuming, but not enforcing, no flow reversal"
    annotation (Dialog(group="Evaporator", tab="Assumptions"));
  parameter Boolean allowFlowReversalCon=true
    "= false to simplify equations, assuming, but not enforcing, no flow reversal"
    annotation (Dialog(group="Condenser", tab="Assumptions"));

  parameter Modelica.SIunits.Time tauHeaTraEva=1200
    "Time constant for heat transfer in temperature sensors in evaporator, default 20 minutes"
    annotation (Dialog(tab="Assumptions", group="Evaporator",enable=transferHeat),         Evaluate=true);
  parameter Modelica.SIunits.Time tauHeaTraCon=1200
    "Time constant for heat transfer in temperature sensors in evaporator, default 20 minutes"
    annotation (Dialog(tab="Assumptions", group="Condenser",enable=transferHeat),Evaluate=true);
  parameter Modelica.SIunits.Temperature TAmbCon_nominal=291.15
    "Fixed ambient temperature for heat transfer of sensors at the condenser side" annotation (               Dialog(tab=
          "Assumptions",                                                                                               group=
          "Condenser",
      enable=transferHeat));

  parameter Modelica.SIunits.Temperature TAmbEva_nominal=273.15
    "Fixed ambient temperature for heat transfer of sensors at the evaporator side"
    annotation (               Dialog(tab="Assumptions",group="Evaporator",enable=transferHeat));

//Initialization
  parameter Modelica.Blocks.Types.Init initType=Modelica.Blocks.Types.Init.InitialState
    "Type of initialization (InitialState and InitialOutput are identical)"
    annotation (Dialog(tab="Initialization", group="Parameters"));
  parameter Modelica.Media.Interfaces.Types.AbsolutePressure pCon_start=
      Medium_con.p_default "Start value of pressure"
    annotation (Evaluate=true,Dialog(tab="Initialization", group="Condenser"));
  parameter Modelica.Media.Interfaces.Types.Temperature TCon_start=Medium_con.T_default
    "Start value of temperature"
    annotation (Evaluate=true,Dialog(tab="Initialization", group="Condenser"));
  parameter Modelica.Media.Interfaces.Types.MassFraction XCon_start[Medium_con.nX]=
     Medium_con.X_default "Start value of mass fractions m_i/m"
    annotation (Evaluate=true,Dialog(tab="Initialization", group="Condenser"));
  parameter Modelica.Media.Interfaces.Types.AbsolutePressure pEva_start=
      Medium_eva.p_default "Start value of pressure"
    annotation (Evaluate=true,Dialog(tab="Initialization", group="Evaporator"));
  parameter Modelica.Media.Interfaces.Types.Temperature TEva_start=Medium_eva.T_default
    "Start value of temperature"
    annotation (Evaluate=true,Dialog(tab="Initialization", group="Evaporator"));
  parameter Modelica.Media.Interfaces.Types.MassFraction XEva_start[Medium_eva.nX]=
     Medium_eva.X_default "Start value of mass fractions m_i/m"
    annotation (Evaluate=true,Dialog(tab="Initialization", group="Evaporator"));
  parameter Real x_start[nthOrder]=zeros(nthOrder)
    "Initial or guess values of states"
    annotation (Dialog(tab="Initialization", group="Refrigerant inertia", enable=use_refIne));
  parameter Real yRefIne_start=0 "Initial or guess value of output (= state)"
    annotation (Dialog(tab="Initialization", group="Refrigerant inertia",enable=initType ==
          Init.InitialOutput and use_refIne));
//Dynamics
  parameter Modelica.Fluid.Types.Dynamics massDynamics=Modelica.Fluid.Types.Dynamics.DynamicFreeInitial
    "Type of mass balance: dynamic (3 initialization options) or steady state"
    annotation (Dialog(tab="Dynamics", group="Equation"));
  parameter Modelica.Fluid.Types.Dynamics energyDynamics=Modelica.Fluid.Types.Dynamics.DynamicFreeInitial
    "Type of energy balance: dynamic (3 initialization options) or steady state"
    annotation (Dialog(tab="Dynamics", group="Equation"));
//Advanced
  parameter Boolean show_TPort=false
    "= true, if actual temperature at port is computed"
    annotation(Dialog(tab="Advanced",group="Diagnostics"));
  parameter Boolean from_dp=false
    "= true, use m_flow = f(dp) else dp = f(m_flow)"
    annotation (Dialog(tab="Advanced", group="Flow resistance"));
  parameter Boolean homotopyInitialization=false "= true, use homotopy method"
    annotation (Dialog(tab="Advanced", group="Flow resistance"));
  parameter Boolean linearized=false
    "= true, use linear relation between m_flow and dp for any flow rate"
    annotation (Dialog(tab="Advanced", group="Flow resistance"));
  AixLib.Fluid.HeatExchangers.EvaporatorCondenserWithCapacity con(
    redeclare final package Medium = Medium_con,
    final allowFlowReversal=allowFlowReversalCon,
    final m_flow_small=1E-4*abs(mFlow_conNominal),
    final show_T=show_TPort,
    final deltaM=deltaM_con,
    final T_start=TCon_start,
    final p_start=pCon_start,
    final use_cap=use_conCap,
    final X_start=XCon_start,
    final from_dp=from_dp,
    final homotopyInitialization=homotopyInitialization,
    final massDynamics=massDynamics,
    final energyDynamics=energyDynamics,
    final is_con=true,
    final V=VCon*scalingFactor,
    final C=CCon*scalingFactor,
    final GOut=GConOut*scalingFactor,
    final m_flow_nominal=mFlow_conNominal*scalingFactor,
    final dp_nominal=dpCon_nominal*scalingFactor,
    final GInn=GConIns*scalingFactor) "Heat exchanger model for the condenser"
    annotation (Placement(transformation(extent={{-16,78},{16,110}})));
  AixLib.Fluid.HeatExchangers.EvaporatorCondenserWithCapacity eva(
    redeclare final package Medium = Medium_eva,
    final deltaM=deltaM_eva,
    final use_cap=use_evaCap,
    final allowFlowReversal=allowFlowReversalEva,
    final m_flow_small=1E-4*abs(mFlow_evaNominal),
    final show_T=show_TPort,
    final T_start=TEva_start,
    final p_start=pEva_start,
    final X_start=XEva_start,
    final from_dp=from_dp,
    final homotopyInitialization=homotopyInitialization,
    final massDynamics=massDynamics,
    final energyDynamics=energyDynamics,
    final is_con=false,
    final V=VEva*scalingFactor,
    final C=CEva*scalingFactor,
    final m_flow_nominal=mFlow_evaNominal*scalingFactor,
    final dp_nominal=dpEva_nominal*scalingFactor,
    final GOut=GEvaOut*scalingFactor,
    GInn=GEvaIns*scalingFactor) "Heat exchanger model for the evaporator"
    annotation (Placement(transformation(extent={{16,-70},{-16,-102}})));
  Modelica.Blocks.Continuous.CriticalDamping heatFlowIneEva(
    final initType=initType,
    final normalized=true,
    final n=nthOrder,
    final f=refIneFre_constant,
    final x_start=x_start,
    final y_start=yRefIne_start) if
                                   use_refIne
    "This n-th order block represents the inertia of the refrigerant cycle and delays the heat flow"
    annotation (Placement(transformation(
        extent={{6,6},{-6,-6}},
        rotation=90,
        origin={-14,-52})));
  Modelica.Blocks.Routing.RealPassThrough realPassThroughnSetCon if
                                                                 not use_refIne
    "Use default nSet value" annotation (Placement(transformation(
        extent={{-6,-6},{6,6}},
        rotation=90,
        origin={16,58})));
  Modelica.Blocks.Continuous.CriticalDamping heatFlowIneCon(
    final initType=initType,
    final normalized=true,
    final n=nthOrder,
    final f=refIneFre_constant,
    final x_start=x_start,
    final y_start=yRefIne_start) if
                                   use_refIne
    "This n-th order block represents the inertia of the refrigerant cycle and delays the heat flow"
    annotation (Placement(transformation(
        extent={{-6,-6},{6,6}},
        rotation=90,
        origin={-16,58})));
  Modelica.Blocks.Routing.RealPassThrough realPassThroughnSetEva if
                                                                 not use_refIne
    "Use default nSet value" annotation (Placement(transformation(
        extent={{6,-6},{-6,6}},
        rotation=90,
        origin={16,-52})));
  Modelica.Blocks.Interfaces.RealInput iceFac_in
    "Input signal for icing factor" annotation (Placement(transformation(
        extent={{-16,-16},{16,16}},
        rotation=90,
        origin={-76,-136})));
  Modelica.Thermal.HeatTransfer.Sources.PrescribedTemperature varTempOutEva if
    use_evaCap "Foreces heat losses according to ambient temperature"
    annotation (Placement(transformation(
        extent={{-8,-8},{8,8}},
        rotation=180,
        origin={68,-108})));
  Modelica.Thermal.HeatTransfer.Sources.PrescribedTemperature varTempOutCon if
    use_conCap "Foreces heat losses according to ambient temperature"
    annotation (Placement(transformation(
        extent={{-8,-8},{8,8}},
        rotation=180,
        origin={68,110})));

  Modelica.Blocks.Interfaces.RealInput nSet
    "Input signal speed for compressor relative between 0 and 1" annotation (Placement(
        transformation(extent={{-132,4},{-100,36}})));
  AixLib.Controls.Interfaces.HeatPumpControlBus
                           sigBusHP
    annotation (Placement(transformation(extent={{-120,-60},{-90,-26}}),
        iconTransformation(extent={{-108,-52},{-90,-26}})));
  AixLib.Fluid.HeatPumps.BaseClasses.InnerCycle innerCycle(redeclare final
      model PerDataHea =
      PerDataHea,
      redeclare final model PerDataChi = PerDataChi,
    final use_revHP=use_revHP,
    final scalingFactor=scalingFactor)                                                   annotation (
      Placement(transformation(
        extent={{-27,-26},{27,26}},
        rotation=90,
        origin={0,-1})));
  Modelica.Blocks.Interfaces.RealInput T_amb_eva(final unit="K", final
      displayUnit="degC")
    "Ambient temperature on the evaporator side"
    annotation (Placement(transformation(extent={{10,-10},{-10,10}},
        rotation=0,
        origin={110,-100})));
  Modelica.Blocks.Interfaces.RealInput T_amb_con(final unit="K", final
      displayUnit="degC")
    "Ambient temperature on the condenser side"
    annotation (Placement(transformation(extent={{-10,10},{10,-10}},
        rotation=180,
        origin={110,100})));

  Modelica.Blocks.Interfaces.BooleanInput modeSet "Set value of HP mode"
    annotation (Placement(transformation(extent={{-132,-36},{-100,-4}})));

  Sensors.TemperatureTwoPort senT_a2(
    redeclare final package Medium = Medium_eva,
    final allowFlowReversal=allowFlowReversalEva,
    final m_flow_small=1E-4*mFlow_evaNominal,
    final initType=initType,
    final T_start=TEva_start,
    final transferHeat=transferHeat,
    final TAmb=TAmbEva_nominal,
    final tauHeaTra=tauHeaTraEva,
    final tau=tauSenT,
    final m_flow_nominal=mFlow_evaNominal*scalingFactor)
    "Temperature at sink inlet" annotation (Placement(transformation(
        extent={{10,-10},{-10,10}},
        rotation=0,
        origin={38,-86})));
  Sensors.TemperatureTwoPort senT_b2(
    redeclare final package Medium = Medium_eva,
    final allowFlowReversal=allowFlowReversalEva,
    final m_flow_small=1E-4*mFlow_evaNominal,
    final initType=initType,
    final T_start=TEva_start,
    final transferHeat=transferHeat,
    final TAmb=TAmbEva_nominal,
    final tauHeaTra=tauHeaTraEva,
    final tau=tauSenT,
    final m_flow_nominal=mFlow_evaNominal*scalingFactor)
    "Temperature at sink outlet" annotation (Placement(transformation(
        extent={{10,-10},{-10,10}},
        rotation=0,
        origin={-52,-86})));
  Sensors.MassFlowRate mFlow_eva(redeclare final package Medium = Medium_eva,
      final allowFlowReversal=allowFlowReversalEva)
    "Mass flow sensor at the evaporator" annotation (Placement(transformation(
        origin={72,-60},
        extent={{10,-10},{-10,10}},
        rotation=0)));
  Sensors.TemperatureTwoPort senT_b1(
    final initType=initType,
    final transferHeat=transferHeat,
    final TAmb=TAmbCon_nominal,
    redeclare final package Medium = Medium_con,
    final allowFlowReversal=allowFlowReversalCon,
    final m_flow_small=1E-4*mFlow_conNominal,
    final T_start=TCon_start,
    final tau=tauSenT,
    final tauHeaTra=tauHeaTraCon,
    final m_flow_nominal=mFlow_conNominal*scalingFactor)
    "Temperature at sink outlet" annotation (Placement(transformation(
        extent={{-10,10},{10,-10}},
        rotation=0,
        origin={38,92})));
  Sensors.TemperatureTwoPort senT_a1(
    final initType=initType,
    final transferHeat=transferHeat,
    redeclare final package Medium = Medium_con,
    final allowFlowReversal=allowFlowReversalCon,
    final m_flow_small=1E-4*mFlow_conNominal,
    final T_start=TCon_start,
    final TAmb=TAmbCon_nominal,
    final tau=tauSenT,
    final m_flow_nominal=mFlow_conNominal*scalingFactor,
    final tauHeaTra=tauHeaTraCon)
    "Temperature at sink inlet" annotation (Placement(transformation(
        extent={{-10,10},{10,-10}},
        rotation=0,
        origin={-34,90})));
  Sensors.MassFlowRate mFlow_con(final allowFlowReversal=allowFlowReversalEva,
      redeclare final package Medium = Medium_con)
    "Mass flow sensor at the evaporator" annotation (Placement(transformation(
        origin={-76,60},
        extent={{-10,10},{10,-10}},
        rotation=0)));

equation

  connect(modeSet, sigBusHP.mode) annotation (Line(points={{-116,-20},{-76,-20},
          {-76,-42.915},{-104.925,-42.915}}, color={255,0,255}), Text(
      string="%second",
      index=1,
      extent={{6,3},{6,3}},
      horizontalAlignment=TextAlignment.Left));
  connect(innerCycle.Pel, sigBusHP.Pel) annotation (Line(points={{28.73,-0.865},
          {38,-0.865},{38,-36},{-52,-36},{-52,-42.915},{-104.925,-42.915}},
                                                  color={0,0,127}), Text(
      string="%second",
      index=1,
      extent={{6,3},{6,3}}));
  connect(nSet, sigBusHP.N) annotation (Line(points={{-116,20},{-76,20},{-76,-42.915},
          {-104.925,-42.915}},
        color={0,0,127}), Text(
      string="%second",
      index=1,
      extent={{6,3},{6,3}},
      horizontalAlignment=TextAlignment.Left));
  connect(innerCycle.QEva, realPassThroughnSetEva.u) annotation (Line(
      points={{-1.77636e-15,-30.7},{-1.77636e-15,-38},{16,-38},{16,-44.8}},
      color={0,0,127},
      pattern=LinePattern.Dash));
  connect(innerCycle.QEva, heatFlowIneEva.u) annotation (Line(
      points={{-1.77636e-15,-30.7},{-1.77636e-15,-38},{-14,-38},{-14,-44.8}},
      color={0,0,127},
      pattern=LinePattern.Dash));
  connect(innerCycle.QCon, heatFlowIneCon.u) annotation (Line(
      points={{1.77636e-15,28.7},{1.77636e-15,30},{0,30},{0,40},{-16,40},{-16,50.8}},
      color={0,0,127},
      pattern=LinePattern.Dash));
  connect(innerCycle.QCon, realPassThroughnSetCon.u) annotation (Line(
      points={{1.77636e-15,28.7},{0,28.7},{0,40},{16,40},{16,50.8}},
      color={0,0,127},
      pattern=LinePattern.Dash));
  connect(sigBusHP, innerCycle.sigBusHP) annotation (Line(
      points={{-105,-43},{-54,-43},{-54,-0.73},{-26.78,-0.73}},
      color={255,204,51},
      thickness=0.5), Text(
      string="%first",
      index=-1,
      extent={{-6,3},{-6,3}},
      horizontalAlignment=TextAlignment.Right));
  connect(iceFac_in, sigBusHP.iceFac) annotation (Line(points={{-76,-136},{-76,-42.915},
          {-104.925,-42.915}}, color={0,0,127}), Text(
      string="%second",
      index=1,
      extent={{-3,6},{-3,6}},
      horizontalAlignment=TextAlignment.Right));
  connect(T_amb_con, varTempOutCon.T) annotation (Line(
      points={{110,100},{84,100},{84,110},{77.6,110}},
      color={0,0,127},
      pattern=LinePattern.Dash));
  connect(varTempOutCon.port, con.port_out) annotation (Line(
      points={{60,110},{0,110}},
      color={191,0,0},
      pattern=LinePattern.Dash));
  connect(T_amb_eva, varTempOutEva.T) annotation (Line(
      points={{110,-100},{94,-100},{94,-108},{77.6,-108}},
      color={0,0,127},
      pattern=LinePattern.Dash));
  connect(eva.port_out, varTempOutEva.port) annotation (Line(
      points={{0,-102},{0,-108},{60,-108}},
      color={191,0,0},
      pattern=LinePattern.Dash));
  connect(port_b2, port_b2) annotation (Line(points={{-100,-60},{-100,-60},{-100,
          -60}}, color={0,127,255}));
  connect(realPassThroughnSetCon.y, con.QFlow_in) annotation (Line(
      points={{16,64.6},{16,77.04},{0,77.04}},
      color={0,0,127},
      pattern=LinePattern.Dash));
  connect(heatFlowIneCon.y, con.QFlow_in) annotation (Line(
      points={{-16,64.6},{-16,77.04},{0,77.04}},
      color={0,0,127},
      pattern=LinePattern.Dash));
  connect(realPassThroughnSetEva.y, eva.QFlow_in) annotation (Line(points={{16,-58.6},
          {16,-69.04},{0,-69.04}}, color={0,0,127}));
  connect(heatFlowIneEva.y, eva.QFlow_in) annotation (Line(points={{-14,-58.6},{
          -14,-69.04},{0,-69.04}}, color={0,0,127}));
  connect(senT_a2.port_b, eva.port_a)
    annotation (Line(points={{28,-86},{16,-86}}, color={0,127,255}));
  connect(senT_b2.port_a, eva.port_b)
    annotation (Line(points={{-42,-86},{-16,-86}}, color={0,127,255}));
  connect(senT_b2.port_b, port_b2) annotation (Line(points={{-62,-86},{-62,-60},
          {-100,-60}}, color={0,127,255}));
  connect(mFlow_eva.port_a, port_a2)
    annotation (Line(points={{82,-60},{100,-60}}, color={0,127,255}));
  connect(mFlow_eva.port_b, senT_a2.port_a) annotation (Line(points={{62,-60},{58,
          -60},{58,-86},{48,-86}}, color={0,127,255}));
  connect(con.port_a, senT_a1.port_b)
    annotation (Line(points={{-16,94},{-20,94},{-20,90},{-24,90}},
                                                 color={0,127,255}));
  connect(senT_a1.port_a, mFlow_con.port_b) annotation (Line(points={{-44,90},{-56,
          90},{-56,60},{-66,60}},     color={0,127,255}));
  connect(port_a1, mFlow_con.port_a)
    annotation (Line(points={{-100,60},{-86,60}}, color={0,127,255}));
  connect(con.port_b, senT_b1.port_a)
    annotation (Line(points={{16,94},{22,94},{22,92},{28,92}},
                                               color={0,127,255}));
  connect(port_b1, senT_b1.port_b) annotation (Line(points={{100,60},{72,60},{72,
          92},{48,92}}, color={0,127,255}));
  connect(senT_b2.T, sigBusHP.T_ret_ev) annotation (Line(points={{-52,-75},{-52,
          -42.915},{-104.925,-42.915}}, color={0,0,127}), Text(
      string="%second",
      index=1,
      extent={{-3,6},{-3,6}},
      horizontalAlignment=TextAlignment.Right));
  connect(senT_a2.T, sigBusHP.T_flow_ev) annotation (Line(points={{38,-75},{38,-36},
          {-52,-36},{-52,-42.915},{-104.925,-42.915}}, color={0,0,127}), Text(
      string="%second",
      index=1,
      extent={{-3,6},{-3,6}},
      horizontalAlignment=TextAlignment.Right));
  connect(mFlow_eva.m_flow, sigBusHP.m_flow_ev) annotation (Line(points={{72,-49},
          {72,-36},{-52,-36},{-52,-42.915},{-104.925,-42.915}}, color={0,0,127}),
      Text(
      string="%second",
      index=1,
      extent={{-3,6},{-3,6}},
      horizontalAlignment=TextAlignment.Right));
  connect(senT_b1.T, sigBusHP.T_ret_co) annotation (Line(points={{38,81},{38,-36},
          {-52,-36},{-52,-42.915},{-104.925,-42.915}}, color={0,0,127}), Text(
      string="%second",
      index=1,
      extent={{-3,-6},{-3,-6}},
      horizontalAlignment=TextAlignment.Right));
  connect(senT_a1.T, sigBusHP.T_flow_co) annotation (Line(points={{-34,79},{-34,
          40},{-76,40},{-76,-42.915},{-104.925,-42.915}}, color={0,0,127}),
      Text(
      string="%second",
      index=1,
      extent={{-3,-6},{-3,-6}},
      horizontalAlignment=TextAlignment.Right));
  connect(mFlow_con.m_flow, sigBusHP.m_flow_co) annotation (Line(points={{-76,
          49},{-76,-42.915},{-104.925,-42.915}}, color={0,0,127}), Text(
      string="%second",
      index=1,
      extent={{-3,-6},{-3,-6}},
      horizontalAlignment=TextAlignment.Right));
  annotation (Icon(coordinateSystem(extent={{-100,-120},{100,120}}), graphics={
        Rectangle(
          extent={{-16,83},{16,-83}},
          fillColor={170,213,255},
          fillPattern=FillPattern.Solid,
          lineColor={0,0,0},
          origin={1,-64},
          rotation=90),
        Rectangle(
          extent={{-17,83},{17,-83}},
          fillColor={255,0,128},
          fillPattern=FillPattern.Solid,
          lineColor={0,0,0},
          origin={1,61},
          rotation=90),
        Text(
          extent={{-76,6},{74,-36}},
          lineColor={28,108,200},
          fillColor={215,215,215},
          fillPattern=FillPattern.Solid,
          textString="%name
"),     Line(
          points={{-9,40},{9,40},{-5,-2},{9,-40},{-9,-40}},
          color={0,0,0},
          smooth=Smooth.None,
          origin={-3,-60},
          rotation=-90),
        Line(
          points={{9,40},{-9,40},{5,-2},{-9,-40},{9,-40}},
          color={0,0,0},
          smooth=Smooth.None,
          origin={-5,56},
          rotation=-90),
        Rectangle(
          extent={{-82,42},{84,-46}},
          lineColor={238,46,47},
          fillColor={0,0,0},
          fillPattern=FillPattern.Solid),
        Line(points={{-88,60},{88,60}}, color={28,108,200}),
        Line(points={{-88,-60},{88,-60}}, color={28,108,200}),
    Line(
    origin={-75.5,-80.333},
    points={{43.5,8.3333},{37.5,0.3333},{25.5,-1.667},{33.5,-9.667},{17.5,-11.667},{27.5,-21.667},{13.5,-23.667},
              {11.5,-31.667}},
      smooth=Smooth.Bezier,
      visible=use_evaCap),
        Polygon(
          points={{-70,-122},{-68,-108},{-58,-114},{-70,-122}},
          lineColor={0,0,0},
          fillPattern=FillPattern.Solid,
          fillColor={0,0,0},
          visible=use_evaCap),
    Line( origin={40.5,93.667},
          points={{39.5,6.333},{37.5,0.3333},{25.5,-1.667},{33.5,-9.667},{17.5,
              -11.667},{27.5,-21.667},{13.5,-23.667},{11.5,-27.667}},
          smooth=Smooth.Bezier,
          visible=use_conCap),
        Polygon(
          points={{86,110},{84,96},{74,102},{86,110}},
          lineColor={0,0,0},
          fillPattern=FillPattern.Solid,
          fillColor={0,0,0},
          visible=use_conCap),
        Line(
          points={{-42,72},{34,72}},
          color={0,0,0},
          arrow={Arrow.None,Arrow.Filled},
          thickness=0.5),
        Line(
          points={{-38,0},{38,0}},
          color={0,0,0},
          arrow={Arrow.None,Arrow.Filled},
          thickness=0.5,
          origin={0,-74},
          rotation=180)}),                Diagram(coordinateSystem(extent={{-100,
            -120},{100,120}})),
    Documentation(revisions="<html>
<ul>
<li>
<i>November 26, 2018&nbsp;</i> by Fabian Wüllhorst: <br/>
First implementation (see issue <a href=\"https://github.com/RWTH-EBC/AixLib/issues/577\">#577</a>)
</li>
</ul>
</html>", info="<html>
<p>This generic grey-box heat pump model uses empirical data to model the refrigerant cycle. The modelling of system inertias and heat losses allow the simulation of transient states. </p>
<p>Resulting in the choosen model structure, several configurations are possible:</p>
<ol>
<li>Compressor type: on/off or inverter controlled</li>
<li>Reversible heat pump / only heating</li>
<li>Source/Sink: Any combination of mediums is possible</li>
<li>Generik: Losses and inertias can be switched on or off.</li>
</ol>
<h4>Concept</h4>
<p>Using a signal bus as a connector, this heat pump model can be easily combined with the new <a href=\"modelica://AixLib.Systems.HeatPumpSystems.HeatPumpSystem\">HeatPumpSystem</a> or several control or security blocks from <a href=\"modelica://AixLib.Controls.HeatPump\">AixLib.Controls.HeatPump</a>. The relevant data is aggregated. In order to control both chillers and heat pumps, both flow and return temperature are aggregated. The mode signal chooses the type of the heat pump. As a result, this model can also be used as a chiller:</p>
<ul>
<li>mode = true: Heating</li>
<li>mode = false: Chilling</li>
</ul>
<p>To model both on/off and inverter controlled heat pumps, the compressor speed is normalizd to a relative value between 0 and 1.</p>
<p>Possible icing of the evaporator is modelled with an input value between 0 and 1.</p>
<p>The model structure is as follows. To understand each submodel, please have a look at the corresponding model information:</p>
<ol>
<li><a href=\"AixLib.Fluid.HeatPumps.BaseClasses.InnerCycle\">InnerCycle</a> (Black Box): Here, the user can use between several input models or just easily create his own, modular black box model. Please look at the model description for more info.</li>
<li>Inertia: A n-order element is used to model system inertias (mass and thermal) of components inside the refrigerant cycle (compressor, pipes, expansion valve)</li>
<li><a href=\"modelica://AixLib.Fluid.HeatExchangers.EvaporatorCondenserWithCapacity\">HeatExchanger</a>: This new model also enable modelling of thermal interias and heat losses in a heat exchanger. Please look at the model description for more info.</li>
</ol>
<h4>Assumptions</h4>
<p>Several assumptions where made in order to model the heat pump. For a detailed description see the corresponding model. </p>
<ol>
<li><a href=\"modelica://AixLib.Fluid.HeatPumps.BaseClasses.PerformanceData.LookUpTable2D\">Performance data 2D</a>: In order to model inverter controlled heat pumps, the compressor speed is scaled <b>linearly</b></li>
<li><a href=\"modelica://AixLib.Fluid.HeatPumps.BaseClasses.PerformanceData.LookUpTable2D\">Performance data 2D</a>: Reduced evaporator power as a result of icing. The icing factor is multiplied with the evaporator power.</li>
<li><b>Inertia</b>: The default value of the n-th order element is set to 3. This follows comparisons with experimental data. Previous heat pump models are using n = 1 as a default. However, it was pointed out that a higher order element fits a real heat pump better in</li>
<li><b>Scaling factor</b>: A scaling facor is implemented for scaling of the heat pump power and capacity. The factor scales the parameters V, m_flow_nominal, C, GIns, GOut and dp_nominal. As a result, the heat pump can supply more heat with the COP staying nearly constant. However, one has to make sure that the supplied pressure difference or mass flow is also scaled with this factor, as the nominal values do not increase said mass flow.</li>
</ol>
<h4>Known Limitations</h4>
<ul>
<li>The n-th order element has a big influence on computational time. Reducing the order or disabling it completly will decrease computational time. </li>
<li>Reversing the mode: A normal 4-way-exchange valve suffers from heat losses and irreversibilities due to switching from one mode to another. Theses losses are not taken into account.</li>
</ul>
</html>"));
end HeatPump;