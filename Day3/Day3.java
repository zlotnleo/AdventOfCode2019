import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.AbstractMap;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

public class Day3 {

    public static class Coord {
        private int x;
        private int y;

        public Coord(int x, int y) {
            this.x = x;
            this.y = y;
        }

        public int getX() {
            return x;
        }

        public int getY() {
            return y;
        }

        public Coord add(Coord other) {
            return new Coord(this.x + other.x, this.y + other.y);
        }

        public int manhattanDistanceTo(Coord other) {
            return Math.abs(this.x - other.x) + Math.abs(this.y - other.y);
        }

        @Override
        public int hashCode() {
            int hash = 7;
            hash = 31 * hash + x;
            hash = 31 * hash + y;
            return hash;
        }

        @Override
        public boolean equals(Object obj) {
            if (!(obj instanceof Coord)) {
                return false;
            }
            Coord other = (Coord) obj;
            return this.x == other.x && this.y == other.y;
        }
    }

    public enum Direction {
        UP, DOWN, LEFT, RIGHT;

        public static Direction get(char s) {
            switch (s) {
            case 'U':
                return UP;
            case 'D':
                return DOWN;
            case 'L':
                return LEFT;
            case 'R':
                return RIGHT;
            default:
                throw new IllegalArgumentException();
            }
        }

        public Coord getDelta() {
            switch (this) {
            case UP:
                return new Coord(0, 1);
            case DOWN:
                return new Coord(0, -1);
            case LEFT:
                return new Coord(-1, 0);
            case RIGHT:
                return new Coord(1, 0);
            default:
                throw new UnknownError();
            }
        }
    }

    class Move {
        public Direction direction;
        public int distance;
    }

    private final Coord ORIGIN = new Coord(0, 0);
    private List<Coord> coords1;
    private List<Coord> coords2;
    private Set<Coord> intersections;

    public Day3(String filename) throws IOException {
        List<String> lines = Files.readAllLines(Paths.get(filename));

        List<Move> moves1 = new ArrayList<Move>();
        for (String moveStr : lines.get(0).split(",")) {
            Move move = new Move();
            move.direction = Direction.get(moveStr.charAt(0));
            move.distance = Integer.parseInt(moveStr.substring(1));
            moves1.add(move);
        }
        coords1 = processMoves(moves1, ORIGIN);

        List<Move> moves2 = new ArrayList<Move>();
        for (String moveStr : lines.get(1).split(",")) {
            Move move = new Move();
            move.direction = Direction.get(moveStr.charAt(0));
            move.distance = Integer.parseInt(moveStr.substring(1));
            moves2.add(move);
        }
        coords2 = processMoves(moves2, ORIGIN);

        findIntersections();
    }

    public int getDistanceToClosestIntersection() {
        int minDistance = -1;
        for (Coord coord : intersections) {
            int currentDistance = coord.manhattanDistanceTo(ORIGIN);
            if (minDistance == -1 || currentDistance < minDistance) {
                minDistance = currentDistance;
            }
        }

        return minDistance;
    }

    public int getMinimumSumStepsToIntersection() {
        int minValue = -1;
        for(Coord intersection : intersections) {
            int currentValue = coords1.indexOf(intersection) + coords2.indexOf(intersection) + 2;
            if(minValue == -1 || currentValue < minValue){
                minValue = currentValue;
            }
        }

        return minValue;
    }

    private static List<Coord> processMoves(List<Move> moves, Coord initial) {
        List<Coord> coords = new ArrayList<Coord>();
        Coord currentCoord = initial;
        for (Move move : moves) {
            for (int i = 0; i < move.distance; i++) {
                currentCoord = currentCoord.add(move.direction.getDelta());
                coords.add(currentCoord);
            }
        }
        return coords;
    }

    private void findIntersections() {
        intersections = new HashSet<Coord>(coords1);
        intersections.retainAll(new HashSet<Coord>(coords2));
    }

    public static void main(String[] argv) throws IOException {
        Day3 day3 = new Day3("input.txt");
        System.out.println(day3.getDistanceToClosestIntersection());
        System.out.println(day3.getMinimumSumStepsToIntersection());
    }
}