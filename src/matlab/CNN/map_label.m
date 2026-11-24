function mapped_label = map_label(label)
    mapping = {{'Sky'};
               {'Building', 'Wall', 'Bridge', 'Tunnel', 'Archway'};
               {'Column_Pole', 'TrafficCone'};
               {'Road', 'LaneMkgsDriv', 'LaneMkgsNonDriv'};
               {'Pavement', 'Sidewalk', 'ParkingBlock', 'RoadShoulder'};
               {'Tree', 'VegetationMisc'};
               {'SignSymbol', 'Misc_Text', 'TrafficLight'};
               {'Fence'};
               {'Car', 'SUVPickupTruck', 'Truck_Bus', 'Train', 'OtherMoving'};
               {'Pedestrian', 'Child', 'CartLuggagePram', 'Animal'};
               {'Bicyclist', 'MotorcycleScooter'};
              };

    mapped_label = 'None';
    for i = 1:numel(mapping)
        class = mapping{i};
        for j = 1:numel(class)
            labelz = class{j};
            if strcmp(labelz, label)
                mapped_label = class{1};
                break;
            end
        end
        if strcmp(mapped_label, 'None') == 0
            break;
        end
    end
end