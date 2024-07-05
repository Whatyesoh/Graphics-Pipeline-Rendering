io.stdout:setvbuf("no")

function love.load()
    theta = 0
    love.window.setFullscreen(true)
    love.window.setVSync(0)

    width = love.graphics.getWidth()
    height = love.graphics.getHeight()

    love.mouse.setPosition(width/2,height/2)
    love.mouse.setVisible(false)

    speed = 15
    vertSpeed = 0

    wheld = 0
    sheld = 0
    aheld = 0
    dheld = 0
    spaceheld = 0
    shiftheld = 0

    cameraTheta = 0

    floor = 1.5

    cameraPos = {0,floor,-5}
    cameraLook = {0,floor,0}

    vertexShader = love.graphics.newShader("project.vert")

    meshes = {}

    createMeshWithNormals("skull.obj",false,"Skull.jpg",0,-10,30,3*math.pi/2,0,0)
    --createMeshWithNormals("ruins.obj",false,"albedo.jpg",0,-10,-30,math.pi * 1.5,3.14159,0)
    --createMeshWithNormals("skull.obj",false,"skull.jpg")
    --createMesh("teapot.obj",true,{0,0,1})

    canvas = love.graphics.newCanvas(width,height, {format = "depth32f", readable = true})
    drawCanvas = love.graphics.newCanvas(width,height)

end

function createMeshWithNormals(file,wireframe,texture,x,y,z,rx,ry,rz)
    table.insert(meshes,{})
    objectData = love.filesystem.read(file)

    vertices = {}
    normals = {}
    textures = {}
    indices = {}

    atypes = {
        {"VertexPosition","float",3},
        {"VertexNormal", "float", 3},
        {"Texture","float",2}
    }

    for i in objectData:gmatch("v +%-?%d+%.%d+ %-?%d+%.%d+ %-?%d+%.%d+") do
        table.insert(vertices,{})
        for j in i:gmatch("%-?%d+%.%d+") do
            table.insert(vertices[#vertices],tonumber(j))
        end
    end

    print(#vertices)

    for i in objectData:gmatch("vn %-?%d+%.%d+ %-?%d+%.%d+ %-?%d+%.%d+") do
        table.insert(normals,{})
        for j in i:gmatch("%-?%d+%.%d+") do
            table.insert(normals[#normals],tonumber(j))
        end
    end

    print(#normals)

    for i in objectData:gmatch("vt %-?%d+%.%d+ %-?%d+%.%d+") do
        table.insert(textures,{})
        for j in i:gmatch("%-?%d+%.%d+") do
            table.insert(textures[#textures],tonumber(j))
        end
    end

    print(#textures)

    obj = love.graphics.newMesh(atypes,#vertices,"triangles","dynamic")

    for i,v in ipairs(vertices) do
        obj:setVertex(i,v[1],v[2],v[3],0,0,0,0,0,0)
    end

    for i in objectData:gmatch("f %-?%d+/%-?%d+/%-?%d+ %-?%d+/%-?%d+/%-?%d+ %-?%d+/%-?%d+/%-?%d+ %-?%d+/%-?%d+/%-?%d+") do
        for j in i:gmatch("%d+/%-?%d+/%-?%d+") do
            attributes = {}
            for k in j:gmatch("%d+") do
                table.insert(attributes,tonumber(k))
            end
            oldx = normals[attributes[3]][1]
            oldy = normals[attributes[3]][2]
            oldz = normals[attributes[3]][3]
            obj:setVertexAttribute(attributes[1],2,oldx,oldy,oldz)
            oldx = textures[attributes[2]][1]
            oldy = textures[attributes[2]][2]
            obj:setVertexAttribute(attributes[1],3,oldx,oldy)
        end
        quad = {}
        for j in i:gmatch(" %-?%d+/") do
            for k in j:gmatch("%d+") do
                table.insert(quad,tonumber(k))
            end
        end
        table.insert(indices,quad[1])
        table.insert(indices,quad[2])
        table.insert(indices,quad[3])
        table.insert(indices,quad[1])
        table.insert(indices,quad[3])
        table.insert(indices,quad[4])
    end

    for i in objectData:gmatch("f %-?%d+/%-?%d+/%-?%d+ %-?%d+/%-?%d+/%-?%d+ %-?%d+/%-?%d+/%-?%d+") do
        for j in i:gmatch("%d+/%-?%d+/%-?%d+") do
            attributes = {}
            for k in j:gmatch("%d+") do
                table.insert(attributes,tonumber(k))
            end
            oldx = normals[attributes[3]][1]
            oldy = normals[attributes[3]][2]
            oldz = normals[attributes[3]][3]
            obj:setVertexAttribute(attributes[1],2,oldx,oldy,oldz)
            oldx = textures[attributes[2]][1]
            oldy = textures[attributes[2]][2]
            obj:setVertexAttribute(attributes[1],3,oldx,oldy)
        end
        for j in i:gmatch(" %-?%d+/") do
            for k in j:gmatch("%d+") do
                table.insert(indices,tonumber(k))
            end
        end
    end

    obj:setVertexMap(indices)
    print(#indices)
    obj:setDrawRange(1,#indices)
    table.insert(meshes[#meshes],obj)
    table.insert(meshes[#meshes],wireframe)
    table.insert(meshes[#meshes],love.graphics.newImage(texture))
    table.insert(meshes[#meshes],x)
    table.insert(meshes[#meshes],y)
    table.insert(meshes[#meshes],z)
    table.insert(meshes[#meshes],rx)
    table.insert(meshes[#meshes],ry)
    table.insert(meshes[#meshes],rz)
end

function createMesh(file, wireframe,color)
    table.insert(meshes,{})
    objectData = love.filesystem.read(file)

    vertices = {}
    indices = {}

    atypes = {
        {"VertexPosition","float",3},
        {"VertexNormal", "float", 3}
    }

    for i in objectData:gmatch("v %-?%d+%.%d+ %-?%d+%.%d+ %-?%d+%.%d+\n") do
        table.insert(vertices,{})
        for j in i:gmatch("%-?%d+%.%d+") do
            table.insert(vertices[#vertices],tonumber(j))
        end
    end

    for i in objectData:gmatch("f %d+ %d+ %d+\n") do
        for j in i:gmatch("%d+") do
            table.insert(indices,tonumber(j))
        end
    end

    obj = love.graphics.newMesh(atypes,#vertices,"triangles","dynamic")

    for i,v in ipairs(vertices) do
        obj:setVertex(i,v[1],v[2],v[3],color[1],color[2],color[3])
    end

    if wireframe == false then
        for i=1,#indices,3 do
            ax, ay, az = obj:getVertexAttribute(indices[i],1)
            bx, by, bz = obj:getVertexAttribute(indices[i+1],1)
            cx, cy, cz = obj:getVertexAttribute(indices[i+2],1)
            p1x = ax - bx
            p1y = ay - by
            p1z = az - bz
            p2x = -ax + cx
            p2y = -ay + cy
            p2z = -az + cz

            nX = p1y * p2z - p1z * p2y
            nY = p1z * p2x - p2z * p1x
            nZ = p1x * p2y - p1y * p2x
            oldX, oldY, oldZ = obj:getVertexAttribute(indices[i],2)
            obj:setVertexAttribute(indices[i],2,oldX+nX,oldY+nY,oldZ+nZ)
            oldX, oldY, oldZ = obj:getVertexAttribute(indices[i+1],2)
            obj:setVertexAttribute(indices[i+1],2,oldX+nX,oldY+nY,oldZ+nZ)
            oldX, oldY, oldZ = obj:getVertexAttribute(indices[i+2],2)
            obj:setVertexAttribute(indices[i+2],2,oldX+nX,oldY+nY,oldZ+nZ)
        end
    end

    obj:setVertexMap(indices)
    obj:setDrawRange(1,#indices)
    table.insert(meshes[#meshes],obj)
    table.insert(meshes[#meshes],wireframe)
end

function love.keypressed(key) 
    if key == "w" then
        wheld = 1
    end
    if key == "a" then
        aheld = 1
    end
    if key == "s" then
        sheld = 1
    end
    if key == "d" then
        dheld = 1
    end
    if key == "lshift" then
        shiftheld = 1
    end
    if key == "space" then
        spaceheld = 1
        if cameraPos[2] == floor then
            vertSpeed = 5
        end
    end
    if key == "escape" then
        love.event.quit()
    end
end

function love.keyreleased(key)
    if key == "w" then
        wheld = 0
    end
    if key == "a" then
        aheld = 0
    end
    if key == "s" then
        sheld = 0
    end
    if key == "d" then
        dheld = 0
    end
    if key == "space" then
        spaceheld = 0
    end
    if key == "lshift" then
        shiftheld = 0
    end
end

function love.mousemoved(x,y,dx,dy)
    cameraTheta = cameraTheta + dx * .005
    if (love.mouse.getX() >= .7 * width or love.mouse.getX() <= .3 * width) then
        love.mouse.setPosition(width/2,height/2)
    end
end

function love.update(dt)

    --[[
    cameraPos[2] = cameraPos[2] + vertSpeed * dt
    if cameraPos[2] < floor then
        vertSpeed = 0
        cameraPos[2] = floor
    else
        vertSpeed = vertSpeed - 10 * dt
    end
    ]]
    if wheld == 1 then
        cameraPos[3] = cameraPos[3] + math.cos(1 * cameraTheta) * dt * speed
        cameraPos[1] = cameraPos[1] - math.sin(cameraTheta) * dt * speed
    end
    if aheld == 1 then
        cameraPos[3] = cameraPos[3] + math.sin(cameraTheta) * dt * speed
        cameraPos[1] = cameraPos[1] + math.cos(1 * cameraTheta) * dt * speed
    end
    if sheld == 1 then
        cameraPos[3] = cameraPos[3] - math.cos(1 * cameraTheta) * dt * speed
        cameraPos[1] = cameraPos[1] + math.sin(cameraTheta) * dt * speed
    end
    if dheld == 1 then
        cameraPos[3] = cameraPos[3] - math.sin(cameraTheta) * dt * speed
        cameraPos[1] = cameraPos[1] - math.cos(1 * cameraTheta) * dt * speed
    end
    if spaceheld == 1 then
        cameraPos[2] = cameraPos[2] + dt * speed
    end
    if shiftheld == 1 then
        cameraPos[2] = cameraPos[2] - dt * speed
    end


    if vertexShader:hasUniform("cameraPos") then
        vertexShader:send("cameraPos",cameraPos)
    end
    if vertexShader:hasUniform("cameraTheta") then
        vertexShader:send("cameraTheta",cameraTheta)
    end

    theta = theta + dt
    if vertexShader:hasUniform("theta") then
        vertexShader:send("theta",theta)
    end
end

function love.draw(dt)
    love.graphics.setCanvas({drawCanvas, depthstencil = canvas})
    
    love.graphics.clear(.3,.6,.8,1,false,1)
    love.graphics.setDepthMode("lequal",true)
    love.graphics.setShader(vertexShader)
    for i,v in ipairs(meshes) do
        love.graphics.setWireframe(v[2])
        if vertexShader:hasUniform("textureToMap") then
            vertexShader:send("textureToMap",v[3])
        end
        if vertexShader:hasUniform("x") then
            vertexShader:send("x",v[4])
        end
        if vertexShader:hasUniform("y") then
            vertexShader:send("y",v[5])
        end
        if vertexShader:hasUniform("z") then
            vertexShader:send("z",v[6])
        end
        if vertexShader:hasUniform("rx") then
            vertexShader:send("rx",v[7])
        end
        if vertexShader:hasUniform("ry") then
            vertexShader:send("ry",v[8])
        end
        if vertexShader:hasUniform("rz") then
            vertexShader:send("rz",v[9])
        end
        love.graphics.draw(v[1],0,0)
    end
    love.graphics.setWireframe(false)
    love.graphics.setCanvas()
    love.graphics.setShader()
    love.graphics.setDepthMode("always",false)
    love.graphics.draw(drawCanvas)
end