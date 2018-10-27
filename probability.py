import random

class Probability:

    NUM_MAP_TYPES = 10
    VARIATIONS_PER_MAP = 3
    NUM_ITERATIONS = 100000
    MAPS_PER_GAME = 4

    MAP_NAMES = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J"] # I ain't makin' more than 10 maps, yo!

    def calculate(self):
        duplicates_found = 0
        previous = self._pick_maps()

        for i in range(self.NUM_ITERATIONS):
            next = self._pick_maps()
            for map in next:
                if map in previous:
                    duplicates_found += 1
                    break
            previous = next            
        
        probability = (100 * duplicates_found / self.NUM_ITERATIONS)
        print("With {} map types and {} variations per type, there is a {}% chance that two subsequent games share at least one map+variation"
            .format(self.NUM_MAP_TYPES, self.VARIATIONS_PER_MAP, probability))

    def _pick_maps(self):
        maps = set()

        temp = self.MAP_NAMES[:self.NUM_MAP_TYPES]
        random.shuffle(temp)
        map_names = temp[:self.MAPS_PER_GAME]

        for map in map_names:
            variation = random.randint(1, self.VARIATIONS_PER_MAP)
            maps.add(map + str(variation))
        
        return maps

Probability().calculate()