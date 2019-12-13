{$mode ObjFPC}
program Day12;

uses
    classes,
    sysutils,
    RegExpr;

type
    TCoord = record
        x, y, z: Integer;
    end;
    TMoon = record
        pos, vel: TCoord;
    end;
    TMoons = Array of TMoon;

function getMoons(filename: String): TMoons;
var
    fileData: TStringList;
    numMoons, i: Integer;
    parseLine : TRegExpr;
begin
    fileData := TStringList.Create;
    fileData.LoadFromFile(filename);

    numMoons := fileData.Count;
    setLength(Result, numMoons);

    parseLine := TRegExpr.Create('^<x=(-?\d+), y=(-?\d+), z=(-?\d+)>$');

    for i := 0 to numMoons - 1 do
    begin
        parseLine.Exec(fileData[i]);
        with Result[i] do
        begin
            pos.x := StrToInt(parseLine.Match[1]);
            pos.y := StrToInt(parseLine.Match[2]);
            pos.z := StrToInt(parseLine.Match[3]);
            vel.x := 0;
            vel.y := 0;
            vel.z := 0;
        end;
    end;
end;

procedure updateVelocity(pos1, pos2: Integer; var vel1, vel2: Integer);
begin
    if pos1 < pos2 then
    begin
        vel1 += 1;
        vel2 -= 1;
    end;
    if pos1 > pos2 then
    begin
        vel1 -= 1;
        vel2 += 1;
    end;
end;

procedure updateState(moons: TMoons);
var
    n, i, j: Integer;
begin
    n := Length(moons);
    for i := 0 to n - 1 do
        for j := i+1 to n - 1 do
        begin
            updateVelocity(moons[i].pos.x, moons[j].pos.x, moons[i].vel.x, moons[j].vel.x);
            updateVelocity(moons[i].pos.y, moons[j].pos.y, moons[i].vel.y, moons[j].vel.y);
            updateVelocity(moons[i].pos.z, moons[j].pos.z, moons[i].vel.z, moons[j].vel.z);
        end;
    for i := 0 to n do
    begin
        moons[i].pos.x := moons[i].pos.x + moons[i].vel.x;
        moons[i].pos.y := moons[i].pos.y + moons[i].vel.y;
        moons[i].pos.z := moons[i].pos.z + moons[i].vel.z;
    end;
end;

function getEnergy(moons: TMoons): Integer;
var
    moon: TMoon;
begin
    Result := 0;
    for moon in moons do
    begin
        Result += (abs(moon.pos.x) + abs(moon.pos.y) + abs(moon.pos.z)) * (abs(moon.vel.x) + abs(moon.vel.y) + abs(moon.vel.z))
    end;
end;

function getCycleAxis(positions: Array of Integer): Int64;
var
    velocities: Array of Integer;
    n, i, j, c: Integer;
    reachedHalf: Boolean;
begin
    n := Length(positions);
    setLength(velocities, Length(positions));
    c := 0;
    repeat
        for i := 0 to n - 1 do
            for j := i + 1 to n - 1 do
                updateVelocity(positions[i], positions[j], velocities[i], velocities[j]);
        reachedHalf := true;
        for i := 0 to n - 1 do
        begin
            if velocities[i] <> 0 then
                reachedHalf := false;
            positions[i] += velocities[i];
        end;
        c += 1;
    until reachedHalf;
    getCycleAxis := c * 2;
end;

function GCD(a, b: Int64): Int64;
var
    temp: Int64;
begin
    while b <> 0 do
    begin
        temp := b;
        b := a mod b;
        a := temp
    end;
    Result := a
end;

function LCM(a, b: Int64): Int64;
begin
    Result := a * b div GCD(a, b);
end;

procedure printMoon(moon: TMoon);
begin
    writeln(
        'pos=<x=', moon.pos.x,
        ', y=', moon.pos.y,
        ', z=', moon.pos.z,
        '>, vel=<x=', moon.vel.x,
        ', y=', moon.vel.y,
        ', z=', moon.vel.z,
        '>'
    )
end;

var
    moons, initialMoons: TMoons;
    positions: Array of Integer;
    i, numMoons, cycleX, cycleY, cycleZ: Integer;
BEGIN
    initialMoons := getMoons('input.txt');
    numMoons := Length(initialMoons);
    setLength(moons, numMoons);
    moons := copy(initialMoons, 0, numMoons);

    for i := 1 to 1000 do
        updateState(moons);
    writeln(getEnergy(moons));

    setLength(positions, numMoons);

    for i := 0 to numMoons - 1 do
        positions[i] := initialMoons[i].pos.x;
    cycleX := getCycleAxis(positions);

    for i := 0 to numMoons - 1 do
        positions[i] := initialMoons[i].pos.y;
    cycleY := getCycleAxis(positions);

    for i := 0 to numMoons - 1 do
        positions[i] := initialMoons[i].pos.z;
    cycleZ := getCycleAxis(positions);

    writeln(LCM(cycleX, LCM(cycleY, cycleZ)));
END.