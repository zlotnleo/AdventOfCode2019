const { readFileSync } = require('fs');

function compute(program, init1, init2) {
    program[1] = init1;
    program[2] = init2;

    let pc = 0;
    let running = true;
    while (running) {
        switch (program[pc]) {
            case 99:
                running = false;
                break;
            case 1:
                program[program[pc + 3]] = program[program[pc + 1]] + program[program[pc + 2]];
                break;
            case 2:
                program[program[pc + 3]] = program[program[pc + 1]] * program[program[pc + 2]];
        }
        pc += 4;
    }
    return program[0];
}

const input = readFileSync("input.txt", "utf-8").split(',').map(s => parseInt(s));

// part one
console.log(compute(input.slice(), 12, 2))

// part 2
const goal = 19690720;
let searching = true;
for(let init1 = 0; init1 <= 99 && searching; init1++){
    for(let init2 = 0; init2 <= 99 && searching; init2++){
        if(compute(input.slice(), init1, init2) === goal){
            console.log(100 * init1 + init2);
            searching = false;
        }
    }
}




