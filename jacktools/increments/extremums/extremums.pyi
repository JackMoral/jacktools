from jacktools.buffer import UpdaterInt, UpdaterDouble


class ExtremumsInt(UpdaterInt):
    def get(self) -> list[int]: pass

class ExtremumsDouble(UpdaterDouble):
    def get(self) -> list[float]: pass