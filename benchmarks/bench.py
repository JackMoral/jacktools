from argparse import ArgumentParser


def main():
    parser = ArgumentParser(description="JackTools benchmarks")
    
    parser.add_argument('--welford_window', action='store_true')

    args = parser.parse_args()
    
    if args.welford_window:
        from stats.welford import bench_welford_window
        bench_welford_window()
        
if __name__ == "__main__":
    main()