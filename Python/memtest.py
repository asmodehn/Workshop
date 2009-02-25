
import sys, pygame, random, time
from pygame.locals import *

class Tile:
	def __init__(self, number, coords, width, id):
		self.hide_number = 0
		self.number = number
		self.coords = coords
		self.font = pygame.font.Font(None, 36)
		self.color = (10, 10, 10)
		self.fontbitmap = self.font.render(str(self.number), 1, self.color)
		self.fontpos = self.fontbitmap.get_rect()
		self.id = id
		#width = max(self.fontpos.width, self.fontpos.height) + 10
		self.rect = pygame.Rect(coords, (width, width))
		# center the font
		x = self.fontpos.width/2
		y = self.fontpos.height/2
		x = coords[0] + width/2 - x
		y = coords[1] + width/2 - y
		self.fontpos.top = y
		self.fontpos.left = x
		self.hit = 0
		self.wrong = 0

	def hit_test(self, coords, id):
		if self.rect.collidepoint(coords):
			self.hit = 1
			self.hide_number = 0
			print "Hit: ", self.number, self.id, id
			if id != self.id:
				self.wrong = 1
		return self.hit
	
	def not_yet_hit(self):
		return self.hit == 0
		
	def is_wrong(self):
		return self.wrong
	
	def hide(self, hide=1):
		self.hide_number = hide
		
	def render(self, surface):
		if self.wrong: pygame.draw.rect(surface, (200, 50, 50), self.rect)
		elif self.hit: pygame.draw.rect(surface, (250, 250, 200), self.rect)
		
		pygame.draw.rect(surface, self.color, self.rect, 2)
		if not self.hide_number:
			surface.blit(self.fontbitmap, self.fontpos)
	
class Game:
	# constants
	STATE_START_DISPLAY = 0
	STATE_DISPLAYING = 1
	STATE_WAITING_FOR_INPUT = 2
	STATE_GAME_OVER = 3
	STATE_DISPLAY_STATS = 4
	
	def __init__(self):
		pass
	
	def init(self):
		pygame.init()
		self.screen = pygame.display.set_mode((800,600))
		pygame.display.set_caption("Basic Memory Game")
		# set up the double buffer
		self.buffer = pygame.Surface(self.screen.get_size())
		#self.buffer = buffer.convert()
		self.buffer.fill((255, 255, 255))
		# the actual tiles
		self.tiles = []
		self.hit_sequence = 0
		self.start = 0
		self.longest_done = 0
		self.fastest_time = 0
		self.ngames = 0
		self.totalgames = 3
		self.totalwon = 0
		
	
	def run(self):
		self.init()
		self.new_game()
		
		while 1:
			if not self.eventloop():
				break
				
			self.update()
			self.screen.blit(self.buffer, (0, 0))
			pygame.display.flip()
			
	def eventloop(self):
		for event in pygame.event.get():
			if event.type == QUIT:
				return 0
			elif event.type == MOUSEBUTTONDOWN:
				print "mousedown: ", event.pos
				if self.state == self.STATE_WAITING_FOR_INPUT:
					print "Checking tiles"
					for tile in self.tiles:
						if tile.not_yet_hit() and tile.hit_test(event.pos, self.hit_sequence):
							self.hit_sequence = self.hit_sequence + 1
							if tile.is_wrong():
								self.state = self.STATE_GAME_OVER
								for tile in self.tiles: tile.hide(0)
								print "Game Over"
								self.ngames = self.ngames + 1
							elif self.hit_sequence == len(self.tiles)-1:
								elapsetime = time.time() - self.start
								print "Congrats"
								self.ngames = self.ngames + 1
								self.state = self.STATE_GAME_OVER
								self.totalwon = self.totalwon + 1
								if len(self.tiles) > self.longest_done:
									self.longest_done = len(self.tiles)
								if self.fastest_time == 0 or elapsetime < self.fastest_time:
									self.fastest_time = elapsetime
								
				elif self.state == self.STATE_GAME_OVER:
					print "Starting new game"
					if self.ngames < self.totalgames:
						self.new_game()
					else:
						self.state = self.STATE_DISPLAY_STATS
				elif self.state == self.STATE_DISPLAY_STATS:
					self.new_game()
					self.ngames = 0
					self.totalwon = 0
					
		return 1
		
	def new_game(self):
		# TODO: randomize tiles
		num = range(1, 10)
		# remove 3
		rand = random.Random()
		pieces = rand.randint(4, 10)
		while len(num) > pieces:
			x = rand.randint(1, 10)
			if x in num:
				num.remove(x)
		
		self.hit_sequence = 0
		self.tiles = []
		coords = []
		tile_width = 50
		id = 0
		for n in num:
			while 1:
				rect = pygame.Rect(rand.randint(100, 400), rand.randint(100, 600), tile_width, tile_width)
				if rect.collidelist(coords) == -1:
					coords.append(rect)
					break
				
			print "Tile: ", n, id
			tile = Tile(n, (rect.top, rect.left), tile_width, id)
			tile.hide(0)
			self.tiles.append( tile )
			id = id + 1
		self.start = 0
		self.state = self.STATE_START_DISPLAY
		
	def update(self):
		self.buffer.fill((255, 255, 255))
		
		if self.state == self.STATE_DISPLAY_STATS:
			font = pygame.font.Font(None, 30)
			stats = "You got %d out of %d correct." % (self.totalwon, self.totalgames)
			bitmap = font.render(stats, 1, (10, 10, 10))
			self.buffer.blit(bitmap, (100, 100))
			
			stats = "Longest memorized: %d" % self.longest_done
			bitmap = font.render(stats, 1, (10, 10, 10))
			self.buffer.blit(bitmap, (100, 150))

			stats = "Fastest time: %4.2fsecs" % self.fastest_time
			bitmap = font.render(stats, 1, (10, 10, 10))
			self.buffer.blit(bitmap, (100, 200))
			
			return
			
		if self.state == self.STATE_START_DISPLAY:
			#print "Start Display"
			if self.start == 0:
				self.start = time.time()
			elif time.time() - self.start > 2:
				self.state = self.STATE_WAITING_FOR_INPUT
				print "Hiding tiles: ", self.start, time.time(), time.time()-self.start
				for tile in self.tiles:
					tile.hide(1)
			
		for tile in self.tiles:
			tile.render(self.buffer)
		
if __name__ == '__main__':
	game = Game()
	game.run()
	