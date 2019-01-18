within AixLib.FastHVAC.Data.CHP.FuelcellSOFC;
record MorrisonSOFC
  extends FuelcellSOFC.BaseDataDefinition(
    P_elRated=2800,
    eta_0=0.642388,
    eta_1=-1.619e-4,
    eta_2=-2.26007e-8,
    r_0=2.0417e2,
    r_1=1.8522e-2,
    r_2=-1.664e-1,
    alpha_0=1.6,
    alpha_1=2,
    T_0=26.5,
    u_0=9.1332e-1,
    u_1=6.7317e-5,
    u_2=-6.406e-8,
    anc_0=1.6619e1,
    anc_1=3.8580e6,
    a_0=1.50976e-6,
    a_1=-7.76656e-7,
    a_2=1.30317e-10,
    a_3=2.83507e-3,
    s_0=2.1070e2,
    s_1=1.0979e-4,
    s_2=2.1256e-1,
    beta_0=2,
    beta_1=2,
    T_1=28.2);
  annotation (Icon(coordinateSystem(preserveAspectRatio=false)), Diagram(
        coordinateSystem(preserveAspectRatio=false)),Documentation(revisions="<html><ul>
  <li>
  <i>Aug 09, 2018&#160;</i> by David Jansen:<br/>
  Integrated and validated data from former master thesis by Steffen Brill
  </li>
 </ul>
</html>", info="<html>
<p>
  Record is used with <a href=
  \"AixLib.FastHVAC.Components.HeatGenerators.CHP.CHPCombined\">AixLib.FastHVAC.Components.CHP.CHPCombined</a>
</p>
<p>
  Source:
</p>
<ul>
<li>
<a href='https://www.sciencedirect.com/science/article/pii/S0378775308016650'> IanBeausoleil-Morrison, The calibration of a model for simulating the thermal and electrical
performance of a 2.8kWAC solid-oxide fuel cell micro-cogeneration device
fuel-cell micro-cogeneration device (2013) </a>
  </li>
 </ul>
</html>"));
end MorrisonSOFC;
