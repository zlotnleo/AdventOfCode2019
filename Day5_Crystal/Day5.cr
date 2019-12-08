class Interpreter
    @program : Array(Int32)
    @inputs : Array(Int32)
    getter outputs

    def initialize(program, inputs)
        @program = program.clone
        @inputs = inputs.clone
        @outputs = Array(Int32).new
    end

    def get_value(index, addr_mode = nil)
        value = @program[index]
        case addr_mode
        when 0
            return @program[value]
        when 1, nil
            return value
        else
            raise Exception.new("Invalid addressing mode")
        end
    end

    def compute
        pc = 0

        while true
            opcode = @program[pc]

            case opcode % 100
            when 1
                @program[get_value(pc + 3)] = get_value(pc + 1, opcode // 100 % 10) + get_value(pc + 2, opcode // 1000 % 10)
                pc += 4
            when 2
                @program[get_value(pc + 3)] = get_value(pc + 1, opcode // 100 % 10) * get_value(pc + 2, opcode // 1000 % 10)
                pc += 4
            when 3
                @program[get_value(pc + 1)] = @inputs.shift
                pc += 2
            when 4
                @outputs.unshift get_value(pc + 1, opcode // 100 % 10)
                pc += 2
            when 5
                pc = if get_value(pc + 1, opcode // 100 % 10) != 0
                    get_value(pc + 2, opcode // 1000 % 10)
                else
                    pc + 3
                end
            when 6
                pc = if get_value(pc + 1, opcode // 100 % 10) == 0
                    get_value(pc + 2, opcode // 1000 % 10)
                else
                    pc + 3
                end
            when 7
                @program[get_value(pc + 3)] = if get_value(pc + 1, opcode // 100 % 10) < get_value(pc + 2, opcode // 1000 % 10) 1 else 0 end
                pc += 4
            when 8
                @program[get_value(pc + 3)] = if get_value(pc + 1, opcode // 100 % 10) == get_value(pc + 2, opcode // 1000 % 10) 1 else 0 end
                pc += 4
            when 99
                break
            end 
        end
    end
end

file = File.new("input.txt")
program = file.gets_to_end.split(',').map(&.to_i)
file.close

interpereter = Interpreter.new(program, [1])
interpereter.compute
puts interpereter.outputs

interpereter = Interpreter.new(program, [5])
interpereter.compute
puts interpereter.outputs

