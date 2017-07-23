Include "Vector.geo";

Macro RotatePoint
    pointId = Arguments[0];
    angle = Arguments[1];
    center[] = Arguments[{2:4}];
    Rotate {{0, 0, 1}, {center[0], center[1], center[2]}, angle}
    {
        Point{pointId};
    }
Return

Macro RotateAirfoilPoint
    // rotates pointId about quarter-chord.
    Arguments[1] *= -1.0;
    Arguments[{2:4}] = {0.25 , 0, 0};
    Call RotatePoint;
Return


Macro SingleBendAirfoil
    aoa = Arguments[0] * Pi / 180;
    bendHeight = Arguments[1];
    bendLocation = Arguments[2];
    thickness = Arguments[3];
    lc = Arguments[4];

    allPoints[] = {};

    Point(ce++) = {0.5 * thickness, 0, 0, lc};
    leCenter = ce - 1;
    Point(ce++) = {bendLocation, bendHeight - thickness, 0, lc};
    peakCenter = ce - 1;
    Point(ce++) = {1 - 0.5 * thickness, 0, 0, lc};
    teCenter = ce - 1;
    allPoints[] += {leCenter, peakCenter, teCenter};

    Arguments[] = {Point{leCenter}, Point{peakCenter}}; Call Vector;
    leToPeak[] = Results[{0:2}];
    Arguments[] = {Point{teCenter}, Point{peakCenter}}; Call Vector;
    teToPeak[] = Results[{0:2}];
    Arguments[] = {1, 0, 0, leToPeak[]}; Call Angle;
    frontAngle = Results[0];
    Arguments[] = {teToPeak[], -1, 0, 0}; Call Angle;
    backAngle = Results[0];
    Printf("INFO: bend angle: %f", 90 - frontAngle * 180 / Pi + 90 - backAngle * 180 / Pi);

    lePoints[] = {};
    Point(ce++) = {0, 0, 0, lc};
    lePoints[] += ce - 1;
    Point(ce++) = {0.5 * thickness, 0.5 * thickness, 0, lc};
    lePoints[] += ce - 1;
    Point(ce++) = {0.5 * thickness, -0.5 * thickness, 0, lc};
    lePoints[] += ce - 1;
    For p In {0:2}
        Arguments[] = {lePoints[p], frontAngle, Point{leCenter}}; Call RotatePoint;
    EndFor
    allPoints[] += lePoints[];

    tePoints[] = {};
    Point(ce++) = {1, 0, 0, lc};
    tePoints[] += ce - 1;
    Point(ce++) = {1 - 0.5 * thickness, 0.5 * thickness, 0, lc};
    tePoints[] += ce - 1;
    Point(ce++) = {1 - 0.5 * thickness, -0.5 * thickness, 0, lc};
    tePoints[] += ce - 1;
    For p In {0:2}
        Arguments[] = {tePoints[p], -backAngle, Point{teCenter}}; Call RotatePoint;
    EndFor
    allPoints[] += tePoints[];

    bendPoints[] = {};
    Point(ce++) = {bendLocation, bendHeight - 1.5 * thickness, 0, 5 * lc};
    bendPoints[] += ce - 1;
    Point(ce++) = {bendLocation - 0.5 * thickness, bendHeight - thickness, 0, lc};
    bendPoints[] += ce - 1;
    Arguments[] = {ce - 1, -(0.5 * Pi - frontAngle), Point{peakCenter}}; Call RotatePoint;
    Point(ce++) = {bendLocation + 0.5 * thickness, bendHeight - thickness, 0, lc};
    bendPoints[] += ce - 1;
    Arguments[] = {ce - 1, (0.5 * Pi - backAngle), Point{peakCenter}}; Call RotatePoint;
    allPoints[] += bendPoints[];

    For p In {0:#allPoints[] - 1}
        Arguments[] = {allPoints[p], aoa};
        Call RotateAirfoilPoint;
    EndFor

    loopLines[] = {};
    Circle(ce++) = {tePoints[0], teCenter, tePoints[1]};
    loopLines[] += ce - 1;
    Line(ce++) = {tePoints[1], bendPoints[2]};
    loopLines[] += ce - 1;
    Circle(ce++) = {bendPoints[2], peakCenter, bendPoints[1]};
    loopLines[] += ce - 1;
    Line(ce++) = {bendPoints[1], lePoints[1]};
    loopLines[] += ce - 1;
    Circle(ce++) = {lePoints[1], leCenter, lePoints[0]};
    loopLines[] += ce - 1;
    Circle(ce++) = {lePoints[0], leCenter, lePoints[2]};
    loopLines[] += ce - 1;
    Line(ce++) = {lePoints[2], bendPoints[0]};
    loopLines[] += ce - 1;
    Line(ce++) = {bendPoints[0], tePoints[2]};
    loopLines[] += ce - 1;
    Circle(ce++) = {tePoints[2], teCenter, tePoints[0]};
    loopLines[] += ce - 1;

    Line Loop(ce++) = loopLines[];
    Results[0] = ce - 1;    
Return
