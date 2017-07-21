Include "Vector.geo";

Macro RotateAirfoilPoint
    // rotates pointId about quarter-chord.
    // aoa is the angle of attack in degrees.
    Rotate {{0, 0, 1}, {0.25, 0, 0}, -aoa * Pi / 180.0}
    {
        Point{pointId};
    }
Return

Macro RotatePoint
    pointId = Arguments[0];
    angle = Arguments[1];
    center[] = Arguments[{2:4}];
    Rotate {{0, 0, 1}, {center[0], center[1], center[2]}, angle}
    {
        Point{pointId};
    }
Return

Macro SingleBendAirfoil
    aoa = Arguments[0] * Pi / 180;
    bendHeight = Arguments[1];
    bendLocation = Arguments[2];
    thickness = Arguments[3];

    Point(ce++) = {0.5 * thickness, 0, 0};
    leCenter = ce - 1;
    Point(ce++) = {bendLocation, bendHeight - thickness, 0};
    peakCenter = ce - 1;
    Point(ce++) = {1 - 0.5 * thickness, 0, 0};
    teCenter = ce - 1;

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
    Point(ce++) = {0, 0, 0};
    lePoints[] += ce - 1;
    Point(ce++) = {0.5 * thickness, 0.5 * thickness, 0};
    lePoints[] += ce - 1;
    Point(ce++) = {0.5 * thickness, -0.5 * thickness, 0};
    lePoints[] += ce - 1;
    For p In {0:2}
        Arguments[] = {lePoints[p], frontAngle, Point{leCenter}}; Call RotatePoint;
    EndFor

    tePoints[] = {};
    Point(ce++) = {1, 0, 0};
    tePoints[] += ce - 1;
    Point(ce++) = {1 - 0.5 * thickness, 0.5 * thickness, 0};
    tePoints[] += ce - 1;
    Point(ce++) = {1 - 0.5 * thickness, -0.5 * thickness, 0};
    tePoints[] += ce - 1;
    For p In {0:2}
        Arguments[] = {tePoints[p], -backAngle, Point{teCenter}}; Call RotatePoint;
    EndFor

    Point(ce++) = {bendLocation, bendHeight - 1.5 * thickness, 0};
    Point(ce++) = {bendLocation - 0.5 * thickness, bendHeight - thickness, 0};
    Arguments[] = {ce - 1, -(0.5 * Pi - frontAngle), Point{peakCenter}}; Call RotatePoint;
    Point(ce++) = {bendLocation + 0.5 * thickness, bendHeight - thickness, 0};
    Arguments[] = {ce - 1, (0.5 * Pi - backAngle), Point{peakCenter}}; Call RotatePoint;

    Line(ce++) = {};
    Line(ce++) = {};
Return
