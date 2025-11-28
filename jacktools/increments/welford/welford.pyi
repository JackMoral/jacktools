from jacktools.buffer import UpdaterInt, UpdaterDouble

class WelfordInt(UpdaterInt):
    def get(self) -> list[float | int]: pass

class WelfordDouble(UpdaterDouble):
    def get(self) -> list[float]: pass