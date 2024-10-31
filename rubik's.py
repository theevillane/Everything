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
    # Example: an unsolved cube in the format 'UUUUUUUUURRRRRRRRRBBBBBBBBBFFFFFFFFFLLLLLLLLLDDDDDDDDD'
    # You can create your own cube string based on the current state.
    cube_state = "UUUUUUUUURRRRRRRRRBBBBBBBBBFFFFFFFFFLLLLLLLLLDDDDDDDDD"  # workout as needed
    solution = solve_rubiks_cube(cube_state)
    print("Solution:", solution)
