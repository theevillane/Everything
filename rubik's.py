import kociemba

def solve_rubiks_cube(cube_string):
    """
    Solve a Rubik's Cube given its current state as a string.
    
    Args:
    cube_string (str): A string representing the cube's current state in the
                       format accepted by the kociemba library.

    Returns:
    str: The solution as a string of moves.
    """
    try:
        solution = kociemba.solve(cube_string)
        return solution
    except Exception as e:
        return f"Error: {e}"

if __name__ == "__main__":
    print("Rubik's cube solver.")
    print("____________________")
    
    #prompt the user for the cube state
    cube_state = input("Enter the state(24 characters long): ").strip()
    
    #validate input length
    if len(cube_state) != 54:
        print("Error: The cube state must be 54 characters long.")
    else:
        solution = solve_rubiks_cube(cube_state)
    print("The solution is:", solution)
