-- random value
function getRandomIntInclusive(min, max)
    min = math.ceil(min);
    max = math.floor(max);
    return math.floor(math.random() * (max - min + 1)) + min;
end

-- square intersecting
function does_square_intersect(Ax1, Ay1, Ax2, Ay2,  Bx1, By1, Bx2, By2) -- A/B {left, top, right, bottom}
    return Ax1 < Bx2 and Ax2 > Bx1 and Ay1 < By2 and Ay2 > By1 -- corrected for flipped Y axis
end
