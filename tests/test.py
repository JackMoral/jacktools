from argparse import ArgumentParser


def main():
    parser = ArgumentParser(description="JackTools tests")
    
    parser.add_argument('--buffer', action='store_true')

    args = parser.parse_args()
    
    if args.buffer:
        from buffer import test_buffer_and_increments
        test_buffer_and_increments()

if __name__ == "__main__":
    main()