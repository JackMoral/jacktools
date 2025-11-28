from argparse import ArgumentParser


def main():
    parser = ArgumentParser(description="JackTools benchmarks")

    parser.add_argument('--buffer', action='store_true')
    args = parser.parse_args()
    
    if args.buffer:
        from buffer import bench_buffer
        bench_buffer()
        
if __name__ == "__main__":
    main()