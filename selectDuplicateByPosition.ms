sel=#()
for i=1 to objects.count-1 do
(
	thisObj = objects[i].pos
	for j=(i+1) to objects.count do
	(
		otherObj = objects[j].pos
		if thisObj == otherObj then
		(
			--print "found"
			append sel objects[i]
		)
	)
)

select sel