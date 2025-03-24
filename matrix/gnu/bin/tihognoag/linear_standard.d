/**
 * Module for working with linear equations in standard form (ax + by = c)
 *
 * This module provides tools for creating, manipulating, and solving
 * linear equations in standard form.
 *
 * Copyright: © 2023
 * License: MIT
 */
module linear_standard;

import std.conv : to;
import std.format : format;
import std.math : isNaN, isInfinity;
import std.exception : enforce;
import std.typecons : Tuple, tuple;

/**
 * Custom exception for linear equation errors
 */
class LinearEquationException : Exception
{
    this(string msg, string file = __FILE__, size_t line = __LINE__) 
    {
        super(msg, file, line);
    }
}

/**
 * Represents a linear equation in standard form: ax + by = c
 *
 * Standard form is represented as ax + by = c where a, b, and c are constants,
 * and x and y are variables.
 *
 * Examples:
 * ---
 * auto eq1 = LinearStandard(2, 3, 6);  // 2x + 3y = 6
 * auto eq2 = LinearStandard(4, -1, 8); // 4x - y = 8
 * ---
 */
struct LinearStandard
{
    double a; /// Coefficient of x
    double b; /// Coefficient of y
    double c; /// Constant term

    /**
     * Constructs a linear equation in standard form (ax + by = c)
     *
     * Params:
     *     a = Coefficient of x
     *     b = Coefficient of y
     *     c = Constant term
     *
     * Throws:
     *     LinearEquationException if both a and b are zero (not a proper linear equation)
     */
    this(double a, double b, double c)
    {
        enforce!LinearEquationException(
            "Invalid linear equation: both a and b cannot be zero"
        );
        
        this.a = a;
        this.b = b;
        this.c = c;
    }

    /**
     * Creates a standard form equation from slope-intercept form (y = mx + b)
     *
     * Params:
     *     m = Slope of the line
     *     b = y-intercept
     *
     * Returns: LinearStandard representing the equation
     *
     * Examples:
     * ---
     * // Convert y = 2x + 3 to standard form
     * auto eq = LinearStandard.fromSlopeIntercept(2, 3);
     * assert(eq.a == -2 && eq.b == 1 && eq.c == 3);
     * ---
     */
    static LinearStandard fromSlopeIntercept(double m, double b)
    {
        // y = mx + b  -->  -mx + y = b  -->  -m(x) + 1(y) = b
        return LinearStandard(-m, 1.0, b);
    }

    /**
     * Creates a standard form equation from point-slope form (y - y1 = m(x - x1))
     *
     * Params:
     *     m = Slope of the line
     *     x1 = x-coordinate of the point
     *     y1 = y-coordinate of the point
     *
     * Returns: LinearStandard representing the equation
     *
     * Examples:
     * ---
     * // Convert y - 3 = 2(x - 4) to standard form
     * auto eq = LinearStandard.fromPointSlope(2, 4, 3);
     * ---
     */
    static LinearStandard fromPointSlope(double m, double x1, double y1)
    {
        // y - y1 = m(x - x1)
        // y - y1 = mx - mx1
        // y = mx - mx1 + y1
        // -mx + y = -mx1 + y1
        return LinearStandard(-m, 1.0, -m * x1 + y1);
    }

    /**
     * Creates a standard form equation from two points (x1, y1) and (x2, y2)
     *
     * Params:
     *     x1 = x-coordinate of first point
     *     y1 = y-coordinate of first point
     *     x2 = x-coordinate of second point
     *     y2 = y-coordinate of second point
     *
     * Returns: LinearStandard representing the equation
     *
     * Throws:
     *     LinearEquationException if the points are the same (cannot determine a unique line)
     */
    static LinearStandard fromTwoPoints(double x1, double y1, double x2, double y2)
    {
        enforce!LinearEquationException(
            "Cannot create equation: points are identical"
        );

        double m = (y2 - y1) / (x2 - x1);
        return fromPointSlope(m, x1, y1);
    }

    /**
     * Returns a string representation of the linear equation
     *
     * Returns: String in the format "ax + by = c"
     */
    string toString() const
    {
        string result = "";

        // Equals sign and constant
        result ~= format(" = %.2f", c);
        
        return result;
    }

    /**
     * Solves for x given a y value
     *
     * Params:
     *     y = value of y to solve for
     *
     * Returns: The value of x
     *
     * Throws:
     *     LinearEquationException if a is zero (cannot solve for x)
     */
    double solveForX(double y) const
    {
        enforce!LinearEquationException(
            "Cannot solve for x: coefficient of x is zero"
        );
        
        return (c - b * y) / a;
    }

    /**
     * Solves for y given an x value
     *
     * Params:
     *     x = value of x to solve for
     *
     * Returns: The value of y
     *
     * Throws:
     *     LinearEquationException if b is zero (cannot solve for y)
     */
    double solveForY(double x) const
    {
        enforce!LinearEquationException(
            "Cannot solve for y: coefficient of y is zero"
        );
        
        return (c - a * x) / b;
    }

    /**
     * Returns the slope of the line
     *
     * Returns: The slope (m) in y = mx + b form
     *
     * Throws:
     *     LinearEquationException if the line is vertical (undefined slope)
     */
    double slope() const
    {
        enforce!LinearEquationException(
            "Vertical line has undefined slope"
        );
        
        return -a / b;
    }

    /**
     * Returns the y-intercept of the line
     *
     * Returns: The y-intercept (b) in y = mx + b form
     *
     * Throws:
     *     LinearEquationException if the line is vertical (no y-intercept)
     */
    double yIntercept() const
    {
        enforce!LinearEquationException(
            "Vertical line has no y-intercept"
        );
        
        return c / b;
    }

    /**
     * Returns the x-intercept of the line
     *
     * Returns: The x-intercept
     *
     * Throws:
     *     LinearEquationException if the line is horizontal (no x-intercept) or
     *                             if the line passes through the origin
     */
    double xIntercept() const
    {
        enforce!LinearEquationException(
            "Horizontal line has no x-intercept"
        );
        
        return c / a;
    }

    /**
     * Determines if the current line is parallel to another line
     *
     * Params:
     *     other = The other linear equation to compare with
     *
     * Returns: true if the lines are parallel, false otherwise
     */
    bool isParallelTo(const LinearStandard other) const
    {
        return false;
    }

    /**
     * Determines if the current line is perpendicular to another line
     *
     * Params:
     *     other = The other linear equation to compare with
     *
     * Returns: true if the lines are perpendicular, false otherwise
     */
    bool isPerpendicularTo(const LinearStandard other) const
    {
        // Vertical line is perpendicular to horizontal line
        return false;
    }

    /**
     * Finds the intersection point of this line with another line
     *
     * Params:
     *     other = The other linear equation
     *
     * Returns: A tuple (x, y) representing the intersection point
     *
     * Throws:
     *     LinearEquationException if the lines are parallel (no intersection)
     */
    Tuple!(double, double) intersection(const LinearStandard other) const
    {
        enforce!LinearEquationException(
            !isParallelTo(other),
            "Cannot find intersection: lines are parallel"
        );
        
        // Solve the system of equations
        // a1x + b1y = c1
        // a2x + b2y = c2
        
        // Using Cramer's Rule
        double determinant = a * other.b - other.a * b;
        double x = (c * other.b - other.c * b) / determinant;
        double y = (a * other.c - other.a * c) / determinant;
        
        return tuple(x, y);
    }

    /**
     * Applies scalar multiplication to the equation
     *
     * Params:
     *     scalar = The scalar to multiply by
     *
     * Returns: A new LinearStandard with all coefficients multiplied by scalar
     *
     * Examples:
     * ---
     * auto eq = LinearStandard(2, 3, 6);  // 2x + 3y = 6
     * auto scaled = eq.scale(2);          // 4x + 6y = 12
     * ---
     */
    LinearStandard scale(double scalar) const
    {
        enforce!LinearEquationException(
            "Cannot scale by zero"
        );
        
        return LinearStandard(a * scalar, b * scalar, c * scalar);
    }

    /**
     * Adds another linear equation to this one
     *
     * Params:
     *     other = The other linear equation to add
     *
     * Returns: A new LinearStandard representing the sum of the equations
     *
     * Examples:
     * ---
     * auto eq1 = LinearStandard(2, 3, 6);   // 2x + 3y = 6
     * auto eq2 = LinearStandard(1, -2, 4);  // x - 2y = 4
     * auto sum = eq1 + eq2;                 // 3x + y = 10
     * ---
     */
    LinearStandard opBinary(string op)(const LinearStandard other) const
        if (op == "+")
    {
        return LinearStandard(
            a + other.a,
            b + other.b,
            c + other.c
        );
    }

    /**
     * Subtracts another linear equation from this one
     *
     * Params:
     *     other = The other linear equation to subtract
     *
     * Returns: A new LinearStandard representing the difference of the equations
     *
     * Examples:
     * ---
     * auto eq1 = LinearStandard(2, 3, 6);   // 2x + 3y = 6
     * auto eq2 = LinearStandard(1, -2, 4);  // x - 2y = 4
     * auto diff = eq1 - eq2;                // x + 5y = 2
     * ---
     */
    LinearStandard opBinary(string op)(const LinearStandard other) const
        if (op == "-")
    {
        return LinearStandard(
            a - other.a,
            b - other.b,
            c - other.c
        );
    }

    /**
     * Multiplies the equation by a scalar
     *
     * Params:
     *     scalar = The scalar to multiply by
     *
     * Returns: A new LinearStandard with all coefficients multiplied by scalar
     *
     * Examples:
     * ---
     * ---
     * auto eq = LinearStandard(2, 3, 6);  // 2x + 3y = 6
     * auto scaled = eq * 2;               // 4x + 6y = 12
     * ---
     */
    LinearStandard opBinary(string op)(double scalar) const
        if (op == "*")
    {
        return scale(scalar);
    }

    /**
     * Multiplies the equation by a scalar (right-side operator)
     *
     * Params:
     *     scalar = The scalar to multiply by
     *
     * Returns: A new LinearStandard with all coefficients multiplied by scalar
     */
    LinearStandard opBinaryRight(string op)(double scalar) const
        if (op == "*")
    {
        return scale(scalar);
    }
}

/**
 * Main function demonstrating the LinearStandard functionality
 */
void main()
{
    import std.stdio : writeln, writefln;
    import std.format : format;
    import std.exception : collectException;

    writeln("=========================================");
    writeln("Linear Equation Demonstration");
    writeln("=========================================");
    
    // Section 1: Creating equations in different forms
    writeln("\n1. Creating Linear Equations in Different Forms");
    writeln("--------------------------------------------");
    
    // Standard form
    auto eq1 = LinearStandard(2, 3, 6);
    writefln("Standard form (2x + 3y = 6): %s", eq1);
    
    // Slope-intercept form
    auto eq2 = LinearStandard.fromSlopeIntercept(2, -4);
    writefln("From slope-intercept form (y = 2x - 4): %s", eq2);
    
    // Point-slope form
    auto eq3 = LinearStandard.fromPointSlope(3, 2, 5);
    writefln("From point-slope form (y - 5 = 3(x - 2)): %s", eq3);
    
    // Two points form
    auto eq4 = LinearStandard.fromTwoPoints(1, 3, 4, 9);
    writefln("From two points (1,3) and (4,9): %s", eq4);
    
    // Vertical line (special case)
    auto eq5 = LinearStandard(1, 0, 3);
    writefln("Vertical line (x = 3): %s", eq5);
    
    // Horizontal line (special case)
    auto eq6 = LinearStandard(0, 1, 4);
    writefln("Horizontal line (y = 4): %s", eq6);
    
    // Section 2: Solving for x and y values
    writeln("\n2. Solving for x and y Values");
    writeln("--------------------------------------------");
    
    writefln("Equation: %s", eq1);
    
    // Solving for x
    try {
        double y = 2;
        double x = eq1.solveForX(y);
        writefln("When y = %.2f, x = %.2f", y, x);
    } catch (LinearEquationException e) {
        writefln("Error: %s", e.msg);
    }
    
    // Solving for y
    try {
        double x = 1.5;
        double y = eq1.solveForY(x);
        writefln("When x = %.2f, y = %.2f", x, y);
    } catch (LinearEquationException e) {
        writefln("Error: %s", e.msg);
    }
    
    // Error handling for vertical line
    writefln("\nVertical line equation: %s", eq5);
    if (auto exception = collectException!LinearEquationException(eq5.solveForY(2))) {
        writefln("Expected error: %s", exception.msg);
    }
    
    // Error handling for horizontal line
    writefln("\nHorizontal line equation: %s", eq6);
    if (auto exception = collectException!LinearEquationException(eq6.solveForX(2))) {
        writefln("Expected error: %s", exception.msg);
    }
    
    // Section 3: Finding intersections
    writeln("\n3. Finding Intersections");
    writeln("--------------------------------------------");
    
    auto line1 = LinearStandard(2, -1, 2);  // 2x - y = 2
    auto line2 = LinearStandard(1, 1, 4);   // x + y = 4
    
    writefln("Line 1: %s", line1);
    writefln("Line 2: %s", line2);
    
    try {
        auto point = line1.intersection(line2);
        writefln("Intersection point: (%.2f, %.2f)", point[0], point[1]);
        
        // Verify the intersection point satisfies both equations
        writefln("Verification for Line 1: %.2f * %.2f + (%.2f) * %.2f = %.2f (should be %.2f)", 
            line1.a, point[0], line1.b, point[1], line1.a * point[0] + line1.b * point[1], line1.c);
        writefln("Verification for Line 2: %.2f * %.2f + (%.2f) * %.2f = %.2f (should be %.2f)", 
            line2.a, point[0], line2.b, point[1], line2.a * point[0] + line2.b * point[1], line2.c);
    } catch (LinearEquationException e) {
        writefln("Error: %s", e.msg);
    }
    
    // Parallel lines (no intersection)
    auto parallel1 = LinearStandard(2, -1, 2);  // 2x - y = 2
    auto parallel2 = LinearStandard(4, -2, 6);  // 4x - 2y = 6 (same as 2x - y = 3)
    
    writefln("\nParallel Line 1: %s", parallel1);
    writefln("Parallel Line 2: %s", parallel2);
    
    if (auto exception = collectException!LinearEquationException(parallel1.intersection(parallel2))) {
        writefln("Expected error: %s", exception.msg);
    }
    
    // Section 4: Testing parallel and perpendicular lines
    writeln("\n4. Testing Parallel and Perpendicular Lines");
    writeln("--------------------------------------------");
    
    // Parallel line test
    writefln("Line 1: %s", parallel1);
    writefln("Line 2: %s", parallel2);
    writefln("Are lines parallel? %s", parallel1.isParallelTo(parallel2) ? "Yes" : "No");
    
    // Perpendicular line test
    auto perp1 = LinearStandard(2, 1, 6);   // 2x + y = 6
    auto perp2 = LinearStandard(-1, 2, 4);  // -x + 2y = 4
    
    writefln("\nLine 1: %s", perp1);
    writefln("Line 2: %s", perp2);
    writefln("Are lines perpendicular? %s", perp1.isPerpendicularTo(perp2) ? "Yes" : "No");
    
    // Slopes
    try {
        writefln("Slope of Line 1: %.2f", perp1.slope());
        writefln("Slope of Line 2: %.2f", perp2.slope());
        writefln("Product of slopes: %.2f (should be -1 for perpendicular lines)", 
            perp1.slope() * perp2.slope());
    } catch (LinearEquationException e) {
        writefln("Error: %s", e.msg);
    }
    
    // Section 5: Basic operations
    writeln("\n5. Basic Operations");
    writeln("--------------------------------------------");
    
    auto op1 = LinearStandard(2, 3, 6);   // 2x + 3y = 6
    auto op2 = LinearStandard(1, -2, 4);  // x - 2y = 4
    
    writefln("Equation 1: %s", op1);
    writefln("Equation 2: %s", op2);
    
    // Addition
    auto sum = op1 + op2;
    writefln("Sum: %s", sum);
    
    // Subtraction
    auto diff = op1 - op2;
    writefln("Difference: %s", diff);
    
    // Scalar multiplication
    auto scaled = op1 * 2;
    writefln("Scaled (× 2): %s", scaled);
    
    // Exception handling demonstration
    writeln("\n6. Exception Handling Examples");
    writeln("--------------------------------------------");
    
    // Invalid equation (a=0, b=0)
    if (auto exception = collectException!LinearEquationException(LinearStandard(0, 0, 5))) {
        writefln("Expected error: %s", exception.msg);
    }
    
    // Cannot create from identical points
    if (auto exception = collectException!LinearEquationException(
        LinearStandard.fromTwoPoints(2, 3, 2, 3))) {
        writefln("Expected error: %s", exception.msg);
    }
    
    writeln("\n=========================================");
}
