import tables, math, strutils, sequtils, sugar, sets

type
    State {.pure.} = enum
        Running, Halted

    Interpreter = ref object
        program: Table[int64, ref int64]
        inputs: seq[int64]
        outputs: seq[int64]
        pc: int64
        relativeBase: int64
        state: State


proc newInterpreter(program: seq[int64], inputs: seq[int64] = @[]): Interpreter =
    let interpreter = Interpreter(
        program: initTable[int64, ref int64](),
        inputs: inputs,
        outputs: @[],
        pc: 0,
        relativeBase: 0,
        state: State.Running
    )
    for i, x in program:
        let n = new(int64)
        n[] = x;
        interpreter.program[i] = n
    return interpreter

method getOrInit(interpreter: Interpreter, key: int64): ref int64 {.base.} =
    if not (key in interpreter.program):
        let n = new(int64)
        n[] = 0
        interpreter.program[key] = n
    interpreter.program[key]
    
method getValue(interpreter: Interpreter, arg_no: int): ref int64 {.base.} =
    let
        addr_mode = interpreter.getOrInit(interpreter.pc)[] div 10 ^ (arg_no + 1) mod 10
        index = interpreter.pc + arg_no
    case addr_mode
    of 0: return interpreter.getOrInit(interpreter.getOrInit(index)[])
    of 1: return interpreter.getOrInit(index)
    of 2: return interpreter.getOrInit(interpreter.relativeBase + interpreter.getOrInit(index)[])
    else: return nil

method compute(interpreter: Interpreter) {.base.} =
    while true:
        let opcode = interpreter.getOrInit(interpreter.pc)[] mod 100
        case opcode
        of 1:
            interpreter.getValue(3)[] = interpreter.getValue(1)[] + interpreter.getValue(2)[]
            interpreter.pc += 4
        of 2:
            interpreter.getValue(3)[] = interpreter.getValue(1)[] * interpreter.getValue(2)[]
            interpreter.pc += 4
        of 3:
            if len(interpreter.inputs) == 0:
                break
            interpreter.getValue(1)[] = interpreter.inputs[0]
            interpreter.inputs.delete(0)
            interpreter.pc += 2
        of 4:
            interpreter.outputs.add(interpreter.getValue(1)[] )
            interpreter.pc += 2
        of 5:
            if interpreter.getValue(1)[] != 0:
                interpreter.pc = interpreter.getValue(2)[]
            else:
                interpreter.pc += 3
        of 6:
            if interpreter.getValue(1)[] == 0:
                interpreter.pc = interpreter.getValue(2)[]
            else:
                interpreter.pc += 3
        of 7:
            if interpreter.getValue(1)[] < interpreter.getValue(2)[]:
                interpreter.getValue(3)[] = 1
            else:
                interpreter.getValue(3)[] = 0
            interpreter.pc += 4
        of 8:
            if interpreter.getValue(1)[] == interpreter.getValue(2)[]:
                interpreter.getValue(3)[] = 1
            else:
                interpreter.getValue(3)[] = 0
            interpreter.pc += 4
        of 9:
            interpreter.relativeBase += interpreter.getValue(1)[]
            interpreter.pc += 2
        of 99:
            interpreter.state = State.Halted
            break
        else:
            discard

proc readInput(filename: string): seq[int64] =
    var file: File
    discard open(file, filename)
    let fileContent = readAll(file)
    return fileContent.split(',').map(parseInt).map(x => int64(x))

type
    Direction {.pure.} = enum
        North = 1,
        South = 2,
        West = 3,
        East = 4

    Coord = tuple[x, y: int]

    Mode {.pure.} = enum
        FindOxygen,
        FindFurthest

proc updateCoord(c: Coord, d: Direction): Coord =
    let (x, y) = c
    case d
    of North: return (x, y - 1)
    of South: return (x, y + 1)
    of West: return (x - 1, y)
    of East: return (x + 1, y)

proc findStepsToOxygen(interpreter: Interpreter, mode: Mode): tuple[interpreter: Interpreter, steps: int] =
    var
        queue: seq[tuple[interpreter: Interpreter, steps: int, position: Coord]] = @[(
            interpreter,
            0,
            (0, 0)
        )]
        added = initHashSet[Coord]()
        furthest = (interpreter: interpreter, steps: 0)
    added.incl(queue[0].position)
    while len(queue) != 0:
        let (interpreter, steps, coord) = queue[0]
        queue.delete(0)
        if steps > furthest.steps:
            furthest = (interpreter, steps)
        interpreter.compute()
        if len(interpreter.outputs) != 0:
            let response = interpreter.outputs[0]
            interpreter.outputs.delete(0)
            case response
            of 0:
                continue
            of 2:
                if mode == Mode.FindOxygen:
                    return (interpreter, steps)
            else: discard
        for dir in Direction:
            let newCoord = updateCoord(coord, dir)
            if not (newCoord in added):
                added.incl(newCoord)
                var interpreterCopy: Interpreter
                interpreterCopy.deepCopy(interpreter)
                interpreterCopy.inputs.add(ord(dir))
                queue.add((interpreterCopy, steps + 1, newCoord))
    if mode == Mode.FindFurthest:
        return furthest


let program = readInput("input.txt")
var
    interpreter = newInterpreter(program)
    stepsToOxygen, furthestFromOxygen: int

(interpreter, stepsToOxygen) = findStepsToOxygen(interpreter, Mode.FindOxygen)
echo stepsToOxygen

(interpreter, furthestFromOxygen) = findStepsToOxygen(interpreter, Mode.FindFurthest)
echo furthestFromOxygen
