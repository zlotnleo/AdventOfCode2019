State = {
    Running = 0,
    Halted = 1
}

Interpreter = {}
function Interpreter:new(program, inputs)
    local new = {
        program = {},
        inputs = inputs,
        outputs = {},
        pc = 0,
        relativeBase = 0,
        state = State.Running
    }
    for _, v in pairs(program) do
        table.insert(new.program, {v})
    end
    self.__index = self
    return setmetatable(new, self)
end

function Interpreter:get_or_init(key)
    key = key + 1
    if (self.program[key] == nil) then
        self.program[key] = {0}
    end
    return self.program[key]
end

function Interpreter:get_value(arg_no)
    local addr_mode = math.floor(self:get_or_init(self.pc)[1] / 10^(arg_no + 1)) % 10
    local index = self.pc + arg_no
    if addr_mode == 0 then
        return self:get_or_init(self:get_or_init(index)[1])
    end
    if addr_mode == 1 then
        return self:get_or_init(index)
    end
    if addr_mode == 2 then
        return self:get_or_init(self.relativeBase + self:get_or_init(index)[1])
    end
end

function Interpreter:compute()
    while (true) do
        local opcode = self:get_or_init(self.pc)[1] % 100
        if opcode == 1 then
            self:get_value(3)[1] = self:get_value(1)[1] + self:get_value(2)[1]
            self.pc = self.pc + 4
        elseif opcode == 2 then
            self:get_value(3)[1] = self:get_value(1)[1] * self:get_value(2)[1]
            self.pc = self.pc + 4
        elseif opcode == 3 then
            local tmp = table.remove(self.inputs, 1)
            if tmp == nil then
                break
            end
            self:get_value(1)[1] = tmp
            self.pc = self.pc + 2
        elseif opcode == 4 then
            table.insert(self.outputs, self:get_value(1)[1])
            self.pc = self.pc + 2
        elseif opcode == 5 then
            if self:get_value(1)[1] ~= 0 then
                self.pc = self:get_value(2)[1]
            else
                self.pc = self.pc + 3
            end
        elseif opcode == 6 then
            if self:get_value(1)[1] == 0 then
                self.pc = self:get_value(2)[1]
            else
                self.pc = self.pc + 3
            end
        elseif opcode == 7 then
            if self:get_value(1)[1] < self:get_value(2)[1] then
                self:get_value(3)[1] = 1
            else
                self:get_value(3)[1] = 0
            end
            self.pc = self.pc + 4
        elseif opcode == 8 then
            if self:get_value(1)[1] == self:get_value(2)[1] then
                self:get_value(3)[1] = 1
            else
                self:get_value(3)[1] = 0
            end
            self.pc = self.pc + 4
        elseif opcode == 9 then
            self.relativeBase = self.relativeBase + self:get_value(1)[1]
            self.pc = self.pc + 2
        elseif opcode == 99 then
            self.state = State.Halted
            break
        end
    end
end

Tile = {
    Empty = 0,
    Wall = 1,
    Block = 2,
    Paddle = 3,
    Ball = 4
}

function load_program(filename)
    local file_content = io.open(filename, "r"):read("all")
    local program = {}
    for instruction in file_content:gmatch("(-?%d+)") do
        table.insert(program, tonumber(instruction))
    end
    return program
end

program = load_program("input.txt")
interpreter = Interpreter:new(program, {})
interpreter:compute()

count = 0
while #interpreter.outputs ~= 0 do
    table.remove(interpreter.outputs, 1)
    table.remove(interpreter.outputs, 1)
    tile = table.remove(interpreter.outputs, 1)
    if tile == Tile.Block then
        count = count + 1
    end
end
print(count)


interpreter = Interpreter:new(program, {})
interpreter:get_or_init(0)[1] = 2
joystick = 0
while(interpreter.state == State.Running) do
    table.insert(interpreter.inputs, joystick)
    interpreter:compute()
    while #interpreter.outputs ~= 0 do
        x = table.remove(interpreter.outputs, 1)
        y = table.remove(interpreter.outputs, 1)
        tile = table.remove(interpreter.outputs, 1)

        if x < 0 then
            score = tile
        else
            if tile == Tile.Ball then
                ballX = x
            elseif tile == Tile.Paddle then
                paddleX = x
            end
        end
    end
    if ballX < paddleX then
        joystick = -1
    elseif ballX > paddleX then
        joystick = 1
    else
        joystick = 0
    end
end
print(score)