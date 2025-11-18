from argparse import ArgumentParser


def main():
    parser = ArgumentParser(description="JackTools tests")
    
    parser.add_argument('--welford_window', action='store_true')

    args = parser.parse_args()
    
    if args.welford_window:
        from stats import test_welford_window
        test_welford_window()
        
if __name__ == "__main__":
    main()