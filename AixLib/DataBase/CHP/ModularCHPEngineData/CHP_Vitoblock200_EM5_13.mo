﻿within AixLib.DataBase.CHP.ModularCHPEngineData;
record CHP_Vitoblock200_EM5_13 "Noch nicht möglich, da Brennwert-Nutzung(T_ExhPowUniOut=?<90°C) Ansonsten aktuell"
  extends AixLib.DataBase.CHP.ModularCHPEngineData.CHPEngDataBaseRecord(
    SIEngine=true,
    VEng=0.001,
    hStr=0.078,
    dCyl=0.072,
    dExh=0.06,
    dCoo=0.024,
    dInn=0.005,
    nEngNominal=25.583,
    Lambda=1,
    z=3,
    eps=12,
    mEng=70,
    etaCHP=0.94,
    etaGen=0.888,
    P_elNominal=5500,
    Q_MaxHea=13500,
    T_ExhPowUniOut=333.15,
    i=0.5);

end CHP_Vitoblock200_EM5_13;
