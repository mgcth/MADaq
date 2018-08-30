function stopImpact

global Impact

stop(Impact.session);
Impact.startButton.String='Start measurement';
Impact.startButton.BackgroundColor=[0 1 0];
Impact.startButton.UserData=0;
Impact.statusStr.String='READY!';
